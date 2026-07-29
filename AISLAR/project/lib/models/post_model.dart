class PostModel {
  final String id;
  final String authorId;
  final String content;
  final List<String> mediaUrls;
  final List<String> mediaTypes;
  final List<String> tags;
  final List<String> mentionIds;
  final bool isPinned;
  final bool isAnnouncement;
  final String status;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.content,
    this.mediaUrls = const [],
    this.mediaTypes = const [],
    this.tags = const [],
    this.mentionIds = const [],
    this.isPinned = false,
    this.isAnnouncement = false,
    this.status = 'published',
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'authorId': authorId,
    'content': content,
    'mediaURLs': mediaUrls,
    'mediaTypes': mediaTypes,
    'tags': tags,
    'mentionIds': mentionIds,
    'isPinned': isPinned,
    'isAnnouncement': isAnnouncement,
    'status': status,
    'likeCount': likeCount,
    'commentCount': commentCount,
    'shareCount': shareCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory PostModel.fromJson(Map<String, dynamic> json, String id) => PostModel(
    id: id,
    authorId: json['authorId'],
    content: json['content'] ?? '',
    mediaUrls: List<String>.from(json['mediaURLs'] ?? []),
    mediaTypes: List<String>.from(json['mediaTypes'] ?? []),
    tags: List<String>.from(json['tags'] ?? []),
    mentionIds: List<String>.from(json['mentionIds'] ?? []),
    isPinned: json['isPinned'] ?? false,
    isAnnouncement: json['isAnnouncement'] ?? false,
    status: json['status'] ?? 'published',
    likeCount: json['likeCount'] ?? 0,
    commentCount: json['commentCount'] ?? 0,
    shareCount: json['shareCount'] ?? 0,
    createdAt: json['createdAt'].toDate(),
    updatedAt: json['updatedAt'].toDate(),
  );
}
