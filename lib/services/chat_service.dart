import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_models.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Getter to access supabase client from outside
  SupabaseClient get supabase => _supabase;

  // Create or get direct chat room
  Future<ChatRoom?> getOrCreateDirectChat(String otherUserId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return null;

      // Check if direct chat already exists
      final existingRoom = await _supabase
          .from('chat_participants')
          .select('''
            room_id,
            chat_room:room_id(
              id, room_type, name, created_at,
              participants:chat_participants(
                user:user_id(id, username, display_name, avatar_url)
              )
            )
          ''')
          .eq('user_id', currentUser.id);

      // Find direct chat with the other user
      for (var participant in existingRoom) {
        final room = participant['chat_room'];
        if (room['room_type'] == 'direct') {
          final participants = room['participants'] as List;
          final hasOtherUser = participants.any(
            (p) => p['user']['id'] == otherUserId,
          );
          if (hasOtherUser && participants.length == 2) {
            return ChatRoom.fromJson(room);
          }
        }
      }

      // Create new direct chat room
      final roomResponse =
          await _supabase
              .from('chat_rooms')
              .insert({'room_type': 'direct', 'created_by': currentUser.id})
              .select()
              .single();

      // Add both users as participants
      await _supabase.from('chat_participants').insert([
        {'room_id': roomResponse['id'], 'user_id': currentUser.id},
        {'room_id': roomResponse['id'], 'user_id': otherUserId},
      ]);

      return ChatRoom.fromJson(roomResponse);
    } catch (e) {
      print('Error creating direct chat: $e');
      return null;
    }
  }

  // Create group chat room
  Future<ChatRoom?> createGroupChat(String groupId, String name) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user found');
        return null;
      }

      // Check if group chat already exists
      final existingRoom =
          await _supabase
              .from('chat_rooms')
              .select('*')
              .eq('group_id', groupId)
              .eq('room_type', 'group')
              .maybeSingle();

      if (existingRoom != null) {
        print('Group chat already exists, returning existing room');
        return ChatRoom.fromJson(existingRoom);
      }

      // Create new group chat room
      final roomResponse =
          await _supabase
              .from('chat_rooms')
              .insert({
                'room_type': 'group',
                'name': name,
                'group_id': groupId,
                'created_by': currentUser.id,
              })
              .select()
              .single();

      print('Created new chat room: ${roomResponse['id']}');

      // Add all group members as participants
      final groupMembers = await _supabase
          .from('group_members')
          .select('user_id')
          .eq('group_id', groupId);

      print('Found ${groupMembers.length} group members');

      if (groupMembers.isNotEmpty) {
        final participants =
            groupMembers
                .map(
                  (member) => {
                    'room_id': roomResponse['id'],
                    'user_id': member['user_id'],
                  },
                )
                .toList();

        await _supabase.from('chat_participants').insert(participants);
        print('Added ${participants.length} participants to chat');
      }

      return ChatRoom.fromJson(roomResponse);
    } catch (e) {
      print('Error creating group chat: $e');
      return null;
    }
  }

  // Get user's chat rooms
  Future<List<ChatRoom>> getUserChatRooms() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return [];

      final response = await _supabase
          .from('chat_participants')
          .select('''
            room:room_id(
              id, room_type, name, created_at,
              group:group_id(name),
              participants:chat_participants(
                user:user_id(id, username, display_name, avatar_url)
              ),
              last_message:messages(content, created_at, sender:sender_id(display_name))
            )
          ''')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return response
          .map<ChatRoom>((json) => ChatRoom.fromJson(json['room']))
          .toList();
    } catch (e) {
      print('Error getting chat rooms: $e');
      return [];
    }
  }

  // Send message
  Future<Message?> sendMessage({
    required String roomId,
    required String content,
    String messageType = 'text',
    String? expenseId,
    String? fileUrl,
    String? replyToId,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return null;

      final response =
          await _supabase
              .from('messages')
              .insert({
                'room_id': roomId,
                'sender_id': currentUser.id,
                'content': content,
                'message_type': messageType,
                'expense_id': expenseId,
                'file_url': fileUrl,
                'reply_to': replyToId,
              })
              .select('''
            *,
            sender:sender_id(id, username, display_name, avatar_url),
            expense:expense_id(title, amount, category),
            reply_to_message:reply_to(content, sender:sender_id(display_name))
          ''')
              .single();

      return Message.fromJson(response);
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Get messages for a room
  Future<List<Message>> getRoomMessages(
    String roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('''
            *,
            sender:sender_id(id, username, display_name, avatar_url),
            expense:expense_id(title, amount, category),
            reply_to_message:reply_to(content, sender:sender_id(display_name))
          ''')
          .eq('room_id', roomId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<Message>((json) => Message.fromJson(json))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Listen to new messages in a room
  Stream<Message> listenToMessages(String roomId) {
    print('Setting up real-time listener for room: $roomId');
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((data) {
          print('Received real-time data: ${data.length} messages');
          if (data.isNotEmpty) {
            // Get the latest message from the stream
            final latestMessage = data.last;
            print('Latest message: ${latestMessage['content']}');
            return Message.fromJson({
              ...latestMessage,
              'sender': latestMessage['sender'] ?? {},
              'expense': latestMessage['expense'],
              'reply_to_message': latestMessage['reply_to_message'],
            });
          }
          return null;
        })
        .where((message) => message != null)
        .cast<Message>();
  }

  // Update last read timestamp
  Future<void> markAsRead(String roomId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      await _supabase
          .from('chat_participants')
          .update({'last_read_at': DateTime.now().toIso8601String()})
          .eq('room_id', roomId)
          .eq('user_id', currentUser.id);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Get unread message count
  Future<int> getUnreadCount(String roomId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return 0;

      // Get last read timestamp
      final participantResponse =
          await _supabase
              .from('chat_participants')
              .select('last_read_at')
              .eq('room_id', roomId)
              .eq('user_id', currentUser.id)
              .single();

      final lastReadAt = participantResponse['last_read_at'];
      if (lastReadAt == null) return 0;

      // Count messages after last read
      final countResponse = await _supabase
          .from('messages')
          .select('id')
          .eq('room_id', roomId)
          .gt('created_at', lastReadAt)
          .neq('sender_id', currentUser.id);

      return countResponse.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Share expense in chat
  Future<Message?> shareExpense(String roomId, String expenseId) async {
    try {
      // Get expense details
      final expenseResponse =
          await _supabase
              .from('expenses')
              .select('title, amount, category')
              .eq('id', expenseId)
              .single();

      final content =
          'Shared expense: ${expenseResponse['title']} - \$${expenseResponse['amount']}';

      return await sendMessage(
        roomId: roomId,
        content: content,
        messageType: 'expense',
        expenseId: expenseId,
      );
    } catch (e) {
      print('Error sharing expense: $e');
      return null;
    }
  }
}
