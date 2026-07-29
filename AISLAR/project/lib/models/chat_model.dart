class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String type;
  final String? mediaUrl;
  final String? replyTo;
  final List<String> mentions;
  final List<String> readBy;
  final List<String> deliveredTo;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    this.type = 'text',
    this.mediaUrl,
    this.replyTo,
    this.mentions = const [],
    this.readBy = const [],
    this.deliveredTo = const [],
    this.isEdited = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'senderId': senderId,
    'content': content,
    'type': type,
    'mediaURL': mediaUrl,
    'replyTo': replyTo,
    'mentions': mentions,
    'readBy': readBy,
    'deliveredTo': deliveredTo,
    'isEdited': isEdited,
    'isDeleted': isDeleted,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory MessageModel.fromJson(Map<String, dynamic> json, String id) => MessageModel(
    id: id,
    roomId: json['roomId'],
    senderId: json['senderId'],
    content: json['content'] ?? '',
    type: json['type'] ?? 'text',
    mediaUrl: json['mediaURL'],
    replyTo: json['replyTo'],
    mentions: List<String>.from(json['mentions'] ?? []),
    readBy: List<String>.from(json['readBy'] ?? []),
    deliveredTo: List<String>.from(json['deliveredTo'] ?? []),
    isEdited: json['isEdited'] ?? false,
    isDeleted: json['isDeleted'] ?? false,
    createdAt: json['createdAt'].toDate(),
    updatedAt: json['updatedAt'].toDate(),
  );
}

class ChatRoomModel {
  final String id;
  final String type;
  final String? name;
  final String? photoUrl;
  final List<String> memberIds;
  final List<String> adminIds;
  final ChatLastMessage? lastMessage;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoomModel({
    required this.id,
    required this.type,
    this.name,
    this.photoUrl,
    required this.memberIds,
    this.adminIds = const [],
    this.lastMessage,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'photoURL': photoUrl,
    'memberIds': memberIds,
    'adminIds': adminIds,
    'lastMessage': lastMessage?.toJson(),
    'isArchived': isArchived,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory ChatRoomModel.fromJson(Map<String, dynamic> json, String id) => ChatRoomModel(
    id: id,
    type: json['type'],
    name: json['name'],
    photoUrl: json['photoURL'],
    memberIds: List<String>.from(json['memberIds'] ?? []),
    adminIds: List<String>.from(json['adminIds'] ?? []),
    lastMessage: json['lastMessage'] != null
        ? ChatLastMessage.fromJson(json['lastMessage'])
        : null,
    isArchived: json['isArchived'] ?? false,
    createdAt: json['createdAt'].toDate(),
    updatedAt: json['updatedAt'].toDate(),
  );
}

class ChatLastMessage {
  final String text;
  final String senderId;
  final String senderName;
  final DateTime sentAt;
  final String type;

  ChatLastMessage({
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.sentAt,
    this.type = 'text',
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'senderId': senderId,
    'senderName': senderName,
    'sentAt': sentAt,
    'type': type,
  };

  factory ChatLastMessage.fromJson(Map<String, dynamic> json) => ChatLastMessage(
    text: json['text'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    sentAt: json['sentAt'].toDate(),
    type: json['type'] ?? 'text',
  );
}
