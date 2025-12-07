import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/social_models.dart';
import '../services/social_service.dart';
import '../utils/logger.dart';

class SocialProvider extends ChangeNotifier {
  final SocialService _socialService = SocialService();
  final SupabaseClient _supabase = Supabase.instance.client;

  UserProfile? _userProfile;
  List<UserProfile> _friends = [];
  List<UserConnection> _friendRequests = [];
  List<ExpenseGroup> _userGroups = [];
  List<CorpusTransaction> _corpusHistory = [];
  bool _isLoading = false;

  // Getters
  UserProfile? get userProfile => _userProfile;
  List<UserProfile> get friends => _friends;
  List<UserConnection> get friendRequests => _friendRequests;
  List<ExpenseGroup> get userGroups => _userGroups;
  List<CorpusTransaction> get corpusHistory => _corpusHistory;
  bool get isLoading => _isLoading;

  // Real-time subscriptions
  RealtimeChannel? _profileSubscription;
  RealtimeChannel? _groupsSubscription;
  RealtimeChannel? _expensesSubscription;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Initialize real-time subscriptions
  Future<void> initializeRealTime() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Subscribe to profile changes
    _profileSubscription =
        _supabase
            .channel('profile_changes')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'user_profiles',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: userId,
              ),
              callback: (payload) {
                _handleProfileChange(payload);
              },
            )
            .subscribe();

    // Subscribe to group changes
    _groupsSubscription =
        _supabase
            .channel('group_changes')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'group_members',
              callback: (payload) {
                _handleGroupChange(payload);
              },
            )
            .subscribe();

    // Subscribe to expense changes for corpus updates
    _expensesSubscription =
        _supabase
            .channel('expense_changes')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'expenses',
              callback: (payload) {
                _handleExpenseChange(payload);
              },
            )
            .subscribe();
  }

  void _handleProfileChange(PostgresChangePayload payload) {
    if (payload.eventType == PostgresChangeEvent.update) {
      loadUserProfile();
    }
  }

  void _handleGroupChange(PostgresChangePayload payload) {
    loadUserGroups();
  }

  void _handleExpenseChange(PostgresChangePayload payload) {
    loadUserProfile(); // Reload to get updated corpus
    loadCorpusHistory();
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final profile = await _socialService.getUserProfile(userId);
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      logger.e('Error loading user profile', error: e);
    }
  }

  // Load friends
  Future<void> loadFriends() async {
    try {
      _setLoading(true);
      final friends = await _socialService.getFriends();
      _friends = friends;
      notifyListeners();
    } catch (e) {
      logger.e('Error loading friends', error: e);
    } finally {
      _setLoading(false);
    }
  }

  // Load friend requests
  Future<void> loadFriendRequests() async {
    try {
      final requests = await _socialService.getFriendRequests();
      _friendRequests = requests;
      notifyListeners();
    } catch (e) {
      logger.e('Error loading friend requests', error: e);
    }
  }

  // Load user groups
  Future<void> loadUserGroups() async {
    try {
      final groups = await _socialService.getUserGroups();
      _userGroups = groups;
      notifyListeners();
    } catch (e) {
      logger.e('Error loading user groups', error: e);
    }
  }

  // Load corpus history
  Future<void> loadCorpusHistory() async {
    try {
      final history = await _socialService.getCorpusHistory();
      _corpusHistory = history;
      notifyListeners();
    } catch (e) {
      logger.e('Error loading corpus history', error: e);
    }
  }

  // Send friend request
  Future<bool> sendFriendRequest(String userProfileId) async {
    try {
      final success = await _socialService.sendFriendRequest(userProfileId);
      if (success) {
        loadFriendRequests(); // Refresh requests
      }
      return success;
    } catch (e) {
      logger.e('Error sending friend request', error: e);
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(String connectionId) async {
    try {
      final success = await _socialService.acceptFriendRequest(connectionId);
      if (success) {
        loadFriendRequests(); // Refresh requests
        loadFriends(); // Refresh friends list
      }
      return success;
    } catch (e) {
      logger.e('Error accepting friend request', error: e);
      return false;
    }
  }

  // Create group
  Future<ExpenseGroup?> createGroup({
    required String name,
    String? description,
    double groupBudget = 0.0,
  }) async {
    try {
      final group = await _socialService.createGroup(
        name: name,
        description: description,
        groupBudget: groupBudget,
      );
      if (group != null) {
        loadUserGroups(); // Refresh groups
      }
      return group;
    } catch (e) {
      logger.e('Error creating group', error: e);
      return null;
    }
  }

  // Join group by code
  Future<bool> joinGroupByCode(String inviteCode) async {
    try {
      final success = await _socialService.joinGroupByCode(inviteCode);
      if (success) {
        loadUserGroups(); // Refresh groups
      }
      return success;
    } catch (e) {
      logger.e('Error joining group', error: e);
      return false;
    }
  }

  // Add expense
  Future<bool> addExpense({
    required String title,
    required double amount,
    required String category,
    required String transactionType,
    String? description,
    String? groupId,
    DateTime? date,
    List<String>? tags,
  }) async {
    try {
      final success = await _socialService.addExpense(
        title: title,
        amount: amount,
        category: category,
        transactionType: transactionType,
        description: description,
        groupId: groupId,
        date: date,
        tags: tags,
      );

      if (success) {
        // Real-time updates will be handled by subscriptions
        // But we can also manually refresh for immediate feedback
        loadUserProfile();
        loadCorpusHistory();
      }

      return success;
    } catch (e) {
      logger.e('Error adding expense', error: e);
      return false;
    }
  }

  // Initialize all data
  Future<void> initialize() async {
    await initializeRealTime();
    await Future.wait([
      loadUserProfile(),
      loadFriends(),
      loadFriendRequests(),
      loadUserGroups(),
      loadCorpusHistory(),
    ]);
  }

  @override
  void dispose() {
    _profileSubscription?.unsubscribe();
    _groupsSubscription?.unsubscribe();
    _expensesSubscription?.unsubscribe();
    super.dispose();
  }
}
