import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/social_models.dart';

class TimelineService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create timeline post
  Future<bool> createPost({
    required String content,
    String postType = 'status',
    String? groupId,
    String? expenseId,
    String visibility = 'friends',
    List<String>? mediaUrls,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      // Get current user profile
      final profileResponse =
          await _supabase
              .from('user_profiles')
              .select('id')
              .eq('user_id', currentUser.id)
              .maybeSingle();

      if (profileResponse == null) return false;

      await _supabase.from('timeline_posts').insert({
        'user_id': profileResponse['id'],
        'group_id': groupId,
        'post_type': postType,
        'content': content,
        'expense_id': expenseId,
        'visibility': visibility,
        'media_urls': mediaUrls,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get timeline feed
  Future<List<TimelinePost>> getTimelineFeed({
    int limit = 20,
    int offset = 0,
    String? groupId,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return [];

      // Get current user profile
      final profileResponse =
          await _supabase
              .from('user_profiles')
              .select('id')
              .eq('user_id', currentUser.id)
              .maybeSingle();

      if (profileResponse == null) return [];

      var query = _supabase.from('timeline_posts').select('''
            *,
            user:user_id(id, username, display_name, avatar_url),
            expense:expense_id(title, amount, category, transaction_type),
            interactions:timeline_interactions(
              id, interaction_type, comment_text,
              user:user_id(username, display_name, avatar_url)
            )
          ''');

      if (groupId != null) {
        // Group-specific timeline
        query = query.eq('group_id', groupId);
      } else {
        // Personal feed - show posts from friends and own posts
        final friendsResponse = await _supabase
            .from('user_connections')
            .select('requester_id, addressee_id')
            .or(
              'requester_id.eq.${profileResponse['id']},addressee_id.eq.${profileResponse['id']}',
            )
            .eq('status', 'accepted');

        List<String> friendIds = [profileResponse['id']]; // Include own posts
        for (var connection in friendsResponse) {
          if (connection['requester_id'] != profileResponse['id']) {
            friendIds.add(connection['requester_id']);
          } else {
            friendIds.add(connection['addressee_id']);
          }
        }

        query = query.inFilter('user_id', friendIds);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<TimelinePost>((json) => TimelinePost.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Like/Unlike post
  Future<bool> toggleLike(String postId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      // Get current user profile
      final profileResponse =
          await _supabase
              .from('user_profiles')
              .select('id')
              .eq('user_id', currentUser.id)
              .maybeSingle();

      if (profileResponse == null) return false;

      // Check if already liked
      final existingLike =
          await _supabase
              .from('timeline_interactions')
              .select()
              .eq('post_id', postId)
              .eq('user_id', profileResponse['id'])
              .eq('interaction_type', 'like')
              .maybeSingle();

      if (existingLike != null) {
        // Unlike
        await _supabase
            .from('timeline_interactions')
            .delete()
            .eq('id', existingLike['id']);
      } else {
        // Like
        await _supabase.from('timeline_interactions').insert({
          'post_id': postId,
          'user_id': profileResponse['id'],
          'interaction_type': 'like',
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Add comment
  Future<bool> addComment(String postId, String commentText) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      // Get current user profile
      final profileResponse =
          await _supabase
              .from('user_profiles')
              .select('id')
              .eq('user_id', currentUser.id)
              .maybeSingle();

      if (profileResponse == null) return false;

      await _supabase.from('timeline_interactions').insert({
        'post_id': postId,
        'user_id': profileResponse['id'],
        'interaction_type': 'comment',
        'comment_text': commentText,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Auto-create posts for certain events
  Future<void> createExpensePost(Expense expense) async {
    try {
      String content;
      String visibility = 'friends';

      if (expense.expenseType == 'group') {
        content =
            'Added ${expense.transactionType == 'income' ? 'income' : 'expense'}: ${expense.title} - \$${expense.amount.toStringAsFixed(2)}';
        visibility = 'group';
      } else {
        if (expense.amount > 100) {
          // Only post significant expenses
          content =
              '${expense.transactionType == 'income' ? 'Earned' : 'Spent'} \$${expense.amount.toStringAsFixed(2)} on ${expense.category}';
        } else {
          return; // Don't post small expenses
        }
      }

      await createPost(
        content: content,
        postType: 'expense',
        groupId: expense.groupId,
        expenseId: expense.id,
        visibility: visibility,
      );
    } catch (e) {
    }
  }

  // Create achievement posts
  Future<void> createAchievementPost(
    String achievement, {
    String? groupId,
  }) async {
    try {
      await createPost(
        content: 'Achievement: $achievement',
        postType: 'achievement',
        groupId: groupId,
        visibility: groupId != null ? 'group' : 'friends',
      );
    } catch (e) {
    }
  }

  // Create budget alert posts
  Future<void> createBudgetAlertPost(
    String alertMessage, {
    String? groupId,
  }) async {
    try {
      await createPost(
        content: 'Alert: $alertMessage',
        postType: 'budget_alert',
        groupId: groupId,
        visibility: groupId != null ? 'group' : 'friends',
      );
    } catch (e) {
    }
  }

  // Get user's own posts
  Future<List<TimelinePost>> getUserPosts(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final response = await _supabase
          .from('timeline_posts')
          .select('''
            *,
            user:user_id(id, username, display_name, avatar_url),
            expense:expense_id(title, amount, category, transaction_type),
            interactions:timeline_interactions(
              id, interaction_type, comment_text,
              user:user_id(username, display_name, avatar_url)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map<TimelinePost>((json) => TimelinePost.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Delete post
  Future<bool> deletePost(String postId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      // Get current user profile
      final profileResponse =
          await _supabase
              .from('user_profiles')
              .select('id')
              .eq('user_id', currentUser.id)
              .maybeSingle();

      if (profileResponse == null) return false;

      await _supabase
          .from('timeline_posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', profileResponse['id']);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get post interactions (likes, comments)
  Future<Map<String, dynamic>> getPostInteractions(String postId) async {
    try {
      final response = await _supabase
          .from('timeline_interactions')
          .select('''
            *,
            user:user_id(username, display_name, avatar_url)
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: false);

      final likes =
          response.where((i) => i['interaction_type'] == 'like').toList();
      final comments =
          response.where((i) => i['interaction_type'] == 'comment').toList();

      return {
        'likes': likes,
        'comments': comments,
        'likeCount': likes.length,
        'commentCount': comments.length,
      };
    } catch (e) {
      return {'likes': [], 'comments': [], 'likeCount': 0, 'commentCount': 0};
    }
  }
}
