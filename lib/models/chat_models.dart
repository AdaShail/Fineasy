import 'social_models.dart';

class ChatRoom {
  final String id;
  final String roomType;
  final String? name;
  final String? groupId;
  final String createdBy;
  final List<ChatParticipant>? participants;
  final ExpenseGroup? group;
  final Message? lastMessage;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.roomType,
    this.name,
    this.groupId,
    required this.createdBy,
    this.participants,
    this.group,
    this.lastMessage,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      roomType: json['room_type'],
      name: json['name'],
      groupId: json['group_id'],
      createdBy: json['created_by'],
      participants:
          json['participants'] != null
              ? (json['participants'] as List)
                  .map((p) => ChatParticipant.fromJson(p))
                  .toList()
              : null,
      group:
          json['group'] != null ? ExpenseGroup.fromJson(json['group']) : null,
      lastMessage:
          json['last_message'] != null &&
                  (json['last_message'] as List).isNotEmpty
              ? Message.fromJson((json['last_message'] as List).first)
              : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get displayName {
    if (roomType == 'group') {
      return name ?? group?.name ?? 'Group Chat';
    } else {
      // For direct chats, show the other participant's name
      if (participants != null && participants!.length == 2) {
        final otherParticipant = participants!.firstWhere(
          (p) => p.user?.userId != createdBy,
          orElse: () => participants!.first,
        );
        return otherParticipant.user?.displayName ?? 'Direct Chat';
      }
      return 'Direct Chat';
    }
  }

  String? get avatarUrl {
    if (roomType == 'direct' &&
        participants != null &&
        participants!.length == 2) {
      final otherParticipant = participants!.firstWhere(
        (p) => p.user?.userId != createdBy,
        orElse: () => participants!.first,
      );
      return otherParticipant.user?.avatarUrl;
    }
    return null;
  }
}

class ChatParticipant {
  final String id;
  final String roomId;
  final String userId;
  final UserProfile? user;
  final DateTime joinedAt;
  final DateTime lastReadAt;

  ChatParticipant({
    required this.id,
    required this.roomId,
    required this.userId,
    this.user,
    required this.joinedAt,
    required this.lastReadAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      joinedAt: DateTime.parse(json['joined_at']),
      lastReadAt: DateTime.parse(json['last_read_at']),
    );
  }
}

class Message {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String messageType;
  final String? expenseId;
  final String? fileUrl;
  final String? replyToId;
  final UserProfile? sender;
  final Expense? expense;
  final Message? replyToMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.expenseId,
    this.fileUrl,
    this.replyToId,
    this.sender,
    this.expense,
    this.replyToMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      content: json['content'],
      messageType: json['message_type'],
      expenseId: json['expense_id'],
      fileUrl: json['file_url'],
      replyToId: json['reply_to'],
      sender:
          json['sender'] != null ? UserProfile.fromJson(json['sender']) : null,
      expense:
          json['expense'] != null ? Expense.fromJson(json['expense']) : null,
      replyToMessage:
          json['reply_to_message'] != null
              ? Message.fromJson(json['reply_to_message'])
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isExpenseMessage => messageType == 'expense' && expense != null;
  bool get isImageMessage => messageType == 'image' && fileUrl != null;
  bool get isFileMessage => messageType == 'file' && fileUrl != null;
  bool get isSystemMessage => messageType == 'system';
  bool get hasReply => replyToId != null;

  String get displayContent {
    switch (messageType) {
      case 'expense':
        return expense != null
            ? 'Shared expense: ${expense!.title} - \$${expense!.amount.toStringAsFixed(2)}'
            : content;
      case 'image':
        return '📷 Image';
      case 'file':
        return '📎 File';
      case 'system':
        return content;
      default:
        return content;
    }
  }
}

class MessageReaction {
  final String id;
  final String messageId;
  final String userId;
  final String emoji;
  final UserProfile? user;
  final DateTime createdAt;

  MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.emoji,
    this.user,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      id: json['id'],
      messageId: json['message_id'],
      userId: json['user_id'],
      emoji: json['emoji'],
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// AutoPilot Chat Models
class ChatMessage {
  final String id;
  final String conversationId;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageType messageType;
  final Map<String, dynamic>? metadata;
  final List<SuggestedAction>? suggestedActions;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    required this.timestamp,
    required this.messageType,
    this.metadata,
    this.suggestedActions,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      content: json['content'],
      sender: MessageSender.values.firstWhere(
        (e) => e.toString().split('.').last == json['sender'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      messageType: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['message_type'],
      ),
      metadata: json['metadata'],
      suggestedActions:
          json['suggested_actions'] != null
              ? (json['suggested_actions'] as List)
                  .map((a) => SuggestedAction.fromJson(a))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'content': content,
      'sender': sender.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'message_type': messageType.toString().split('.').last,
      'metadata': metadata,
      'suggested_actions': suggestedActions?.map((a) => a.toJson()).toList(),
    };
  }
}

enum MessageSender { user, ai }

enum MessageType { text, voice, error, system }

class SuggestedAction {
  final String id;
  final String title;
  final String? description;
  final ActionType type;
  final Map<String, dynamic>? parameters;
  final bool requiresConfirmation;

  SuggestedAction({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.parameters,
    this.requiresConfirmation = false,
  });

  factory SuggestedAction.fromJson(Map<String, dynamic> json) {
    return SuggestedAction(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ActionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      parameters: json['parameters'],
      requiresConfirmation: json['requires_confirmation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'parameters': parameters,
      'requires_confirmation': requiresConfirmation,
    };
  }
}

enum ActionType {
  sendReminder,
  schedulePayment,
  generateReport,
  viewDetails,
  executeWorkflow,
  updateSettings,
}

class AIResponse {
  final String content;
  final Map<String, dynamic>? metadata;
  final List<SuggestedAction>? suggestedActions;
  final double? confidence;

  AIResponse({
    required this.content,
    this.metadata,
    this.suggestedActions,
    this.confidence,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      content: json['content'],
      metadata: json['metadata'],
      suggestedActions:
          json['suggested_actions'] != null
              ? (json['suggested_actions'] as List)
                  .map((a) => SuggestedAction.fromJson(a))
                  .toList()
              : null,
      confidence: json['confidence']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'metadata': metadata,
      'suggested_actions': suggestedActions?.map((a) => a.toJson()).toList(),
      'confidence': confidence,
    };
  }
}
