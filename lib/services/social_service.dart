import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/social_models.dart';

class SocialService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // User Profile Management
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase
              .from('user_profiles')
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<UserProfile?> createUserProfile({
    required String username,
    required String displayName,
    String? bio,
    String? avatarUrl,
    String? phone,
    double monthlyBudget = 0.0,
  }) async {
    try {
      final response =
          await _supabase
              .from('user_profiles')
              .insert({
                'user_id': _supabase.auth.currentUser!.id,
                'username': username,
                'display_name': displayName,
                'bio': bio,
                'avatar_url': avatarUrl,
                'phone': phone,
                'monthly_budget': monthlyBudget,
              })
              .select()
              .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error creating user profile: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      await _supabase
          .from('user_profiles')
          .update(profile.toJson())
          .eq('user_id', _supabase.auth.currentUser!.id);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Friend/Connection System
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('user_profiles')
          .select()
          .or('username.ilike.%$query%,display_name.ilike.%$query%')
          .eq('is_public', true)
          .neq('user_id', currentUserId ?? '') // Exclude current user
          .limit(20);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Get all users for testing/admin purposes
  Future<List<UserProfile>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('is_public', true)
          .limit(100);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<bool> sendFriendRequest(String addresseeProfileId) async {
    try {
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) {
        print('Current user profile not found');
        return false;
      }

      // Check if connection already exists
      final existingConnection =
          await _supabase
              .from('user_connections')
              .select()
              .or(
                'requester_id.eq.${currentProfile.id},addressee_id.eq.${currentProfile.id}',
              )
              .or(
                'requester_id.eq.$addresseeProfileId,addressee_id.eq.$addresseeProfileId',
              )
              .maybeSingle();

      if (existingConnection != null) {
        print('Connection already exists');
        return false;
      }

      await _supabase.from('user_connections').insert({
        'requester_id': currentProfile.id,
        'addressee_id': addresseeProfileId,
        'status': 'pending',
      });
      return true;
    } catch (e) {
      print('Error sending friend request: $e');
      return false;
    }
  }

  Future<bool> acceptFriendRequest(String connectionId) async {
    try {
      await _supabase
          .from('user_connections')
          .update({'status': 'accepted'})
          .eq('id', connectionId);
      return true;
    } catch (e) {
      print('Error accepting friend request: $e');
      return false;
    }
  }

  Future<List<UserConnection>> getFriendRequests() async {
    try {
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) return [];

      final response = await _supabase
          .from('user_connections')
          .select('''
            *,
            requester:requester_id(id, username, display_name, avatar_url),
            addressee:addressee_id(id, username, display_name, avatar_url)
          ''')
          .eq('addressee_id', currentProfile.id)
          .eq('status', 'pending');

      return response
          .map<UserConnection>((json) => UserConnection.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting friend requests: $e');
      return [];
    }
  }

  Future<List<UserProfile>> getFriends() async {
    try {
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) return [];

      final response = await _supabase
          .from('user_connections')
          .select('''
            requester:requester_id(id, username, display_name, avatar_url, total_corpus),
            addressee:addressee_id(id, username, display_name, avatar_url, total_corpus)
          ''')
          .or(
            'requester_id.eq.${currentProfile.id},addressee_id.eq.${currentProfile.id}',
          )
          .eq('status', 'accepted');

      List<UserProfile> friends = [];
      for (var connection in response) {
        if (connection['requester']['id'] != currentProfile.id) {
          friends.add(UserProfile.fromJson(connection['requester']));
        } else {
          friends.add(UserProfile.fromJson(connection['addressee']));
        }
      }
      return friends;
    } catch (e) {
      print('Error getting friends: $e');
      return [];
    }
  }

  // Group Management
  Future<ExpenseGroup?> createGroup({
    required String name,
    String? description,
    double groupBudget = 0.0,
  }) async {
    try {
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) return null;

      // Generate a unique invite code
      final inviteCode = _generateInviteCode();

      final response =
          await _supabase
              .from('expense_groups')
              .insert({
                'name': name,
                'description': description,
                'creator_id': currentProfile.id,
                'group_budget': groupBudget,
                'invite_code': inviteCode,
                'is_active': true,
              })
              .select('''
                id, name, description, invite_code, group_budget, created_at, updated_at, creator_id, is_active,
                creator:creator_id(id, username, display_name, user_id, created_at, updated_at)
              ''')
              .single();

      // Manually add creator as admin member if no database trigger exists
      try {
        await _supabase.from('group_members').insert({
          'group_id': response['id'],
          'user_id': currentProfile.id,
          'role': 'admin',
        });
      } catch (memberError) {
        print(
          'Note: Creator might already be added by database trigger: $memberError',
        );
      }

      return ExpenseGroup.fromJson(response);
    } catch (e) {
      print('Error creating group: $e');
      return null;
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 8; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }

  Future<bool> joinGroupByCode(String inviteCode) async {
    try {
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) return false;

      // Find group by invite code
      final groupResponse =
          await _supabase
              .from('expense_groups')
              .select('id, name, is_active')
              .eq('invite_code', inviteCode.toUpperCase())
              .eq('is_active', true)
              .maybeSingle();

      if (groupResponse == null) {
        print('Group not found with invite code: $inviteCode');
        return false;
      }

      // Check if user is already a member
      final existingMember =
          await _supabase
              .from('group_members')
              .select('id')
              .eq('group_id', groupResponse['id'])
              .eq('user_id', currentProfile.id)
              .maybeSingle();

      if (existingMember != null) {
        print('User is already a member of this group');
        return true; // Already a member, consider it success
      }

      // Add user to group
      await _supabase.from('group_members').insert({
        'group_id': groupResponse['id'],
        'user_id': currentProfile.id,
        'role': 'member',
      });

      print('Successfully joined group: ${groupResponse['name']}');
      return true;
    } catch (e) {
      print('Error joining group: $e');
      return false;
    }
  }

  Future<List<ExpenseGroup>> getUserGroups() async {
    try {
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) {
        print('No current profile found for user groups');
        return [];
      }

      print('Loading groups for profile: ${currentProfile.id}');

      final response = await _supabase
          .from('group_members')
          .select('''
            group:group_id(
              id, name, description, invite_code, group_budget, created_at, updated_at,
              creator:creator_id(id, username, display_name, user_id, created_at, updated_at)
            )
          ''')
          .eq('user_id', currentProfile.id);

      print('Group members response: $response');

      final groups =
          response
              .where((item) => item['group'] != null)
              .map<ExpenseGroup>((json) => ExpenseGroup.fromJson(json['group']))
              .toList();

      print('Found ${groups.length} groups');
      return groups;
    } catch (e) {
      print('Error getting user groups: $e');
      return [];
    }
  }

  // Expense Management
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
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) return false;

      await _supabase.from('expenses').insert({
        'user_id': currentProfile.id,
        'group_id': groupId,
        'title': title,
        'description': description,
        'amount': amount,
        'category': category,
        'transaction_type': transactionType,
        'date': (date ?? DateTime.now()).toIso8601String().split('T')[0],
        'tags': tags,
        'expense_type': groupId != null ? 'group' : 'personal',
      });

      return true;
    } catch (e) {
      print('Error adding expense: $e');
      return false;
    }
  }

  Future<List<Expense>> getExpenses({
    String? groupId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) return [];

      var query = _supabase.from('expenses').select('''
            *,
            user:user_id(username, display_name, avatar_url),
            group:group_id(name)
          ''');

      if (groupId != null) {
        query = query.eq('group_id', groupId);
      } else {
        query = query.eq('user_id', currentProfile.id);
      }

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('date', ascending: false);

      return response.map<Expense>((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      print('Error getting expenses: $e');
      return [];
    }
  }

  // Corpus Tracking
  Future<List<CorpusTransaction>> getCorpusHistory({int limit = 50}) async {
    try {
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) return [];

      final response = await _supabase
          .from('corpus_transactions')
          .select('''
            *,
            expense:expense_id(title, category)
          ''')
          .eq('user_id', currentProfile.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map<CorpusTransaction>((json) => CorpusTransaction.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting corpus history: $e');
      return [];
    }
  }

  // Financial Tasks
  Future<bool> addFinancialTask({
    required String title,
    String? description,
    double? targetAmount,
    DateTime? dueDate,
    String taskType = 'goal',
    String priority = 'medium',
  }) async {
    try {
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) return false;

      await _supabase.from('financial_tasks').insert({
        'user_id': currentProfile.id,
        'title': title,
        'description': description,
        'target_amount': targetAmount,
        'due_date': dueDate?.toIso8601String().split('T')[0],
        'task_type': taskType,
        'priority': priority,
      });

      return true;
    } catch (e) {
      print('Error adding financial task: $e');
      return false;
    }
  }

  Future<List<FinancialTask>> getFinancialTasks({
    String status = 'active',
  }) async {
    try {
      final currentProfile = await getUserProfile(
        _supabase.auth.currentUser!.id,
      );
      if (currentProfile == null) return [];

      final response = await _supabase
          .from('financial_tasks')
          .select()
          .eq('user_id', currentProfile.id)
          .eq('status', status)
          .order('due_date', ascending: true);

      return response
          .map<FinancialTask>((json) => FinancialTask.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting financial tasks: $e');
      return [];
    }
  }
}
