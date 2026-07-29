class DonationModel {
  final String id;
  final String donorId;
  final double amount;
  final String currency;
  final String fundType;
  final String paymentMethod;
  final String paymentReference;
  final String? receiptUrl;
  final String? message;
  final bool isAnonymous;
  final String status;
  final String? campaignId;
  final DateTime createdAt;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.amount,
    this.currency = 'NGN',
    required this.fundType,
    this.paymentMethod = 'transfer',
    required this.paymentReference,
    this.receiptUrl,
    this.message,
    this.isAnonymous = false,
    this.status = 'pending',
    this.campaignId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'donorId': donorId,
    'amount': amount,
    'currency': currency,
    'fundType': fundType,
    'paymentMethod': paymentMethod,
    'paymentReference': paymentReference,
    'receiptURL': receiptUrl,
    'message': message,
    'isAnonymous': isAnonymous,
    'status': status,
    'campaignId': campaignId,
    'createdAt': createdAt,
  };

  factory DonationModel.fromJson(Map<String, dynamic> json, String id) => DonationModel(
    id: id,
    donorId: json['donorId'],
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] ?? 'NGN',
    fundType: json['fundType'],
    paymentMethod: json['paymentMethod'] ?? 'transfer',
    paymentReference: json['paymentReference'],
    receiptUrl: json['receiptURL'],
    message: json['message'],
    isAnonymous: json['isAnonymous'] ?? false,
    status: json['status'] ?? 'pending',
    campaignId: json['campaignId'],
    createdAt: json['createdAt'].toDate(),
  );
}

class PollModel {
  final String id;
  final String title;
  final String? description;
  final String type;
  final List<PollOption> options;
  final String createdBy;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isAnonymous;
  final List<String> allowedRoles;
  final int totalVotes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PollModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.options,
    required this.createdBy,
    required this.startsAt,
    required this.endsAt,
    this.isAnonymous = false,
    this.allowedRoles = const [],
    this.totalVotes = 0,
    this.status = 'draft',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'type': type,
    'options': options.map((o) => o.toJson()).toList(),
    'createdBy': createdBy,
    'startsAt': startsAt,
    'endsAt': endsAt,
    'isAnonymous': isAnonymous,
    'allowedRoles': allowedRoles,
    'totalVotes': totalVotes,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory PollModel.fromJson(Map<String, dynamic> json, String id) => PollModel(
    id: id,
    title: json['title'],
    description: json['description'],
    type: json['type'],
    options: (json['options'] as List).map((o) => PollOption.fromJson(o)).toList(),
    createdBy: json['createdBy'],
    startsAt: json['startsAt'].toDate(),
    endsAt: json['endsAt'].toDate(),
    isAnonymous: json['isAnonymous'] ?? false,
    allowedRoles: List<String>.from(json['allowedRoles'] ?? []),
    totalVotes: json['totalVotes'] ?? 0,
    status: json['status'] ?? 'draft',
    createdAt: json['createdAt'].toDate(),
    updatedAt: json['updatedAt'].toDate(),
  );
}

class PollOption {
  final String id;
  final String text;

  PollOption({required this.id, required this.text});

  Map<String, dynamic> toJson() => {'id': id, 'text': text};

  factory PollOption.fromJson(Map<String, dynamic> json) => PollOption(
    id: json['id'],
    text: json['text'],
  );
}

class AlbumModel {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final String type;
  final String createdBy;
  final bool isFeatured;
  final int photoCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  AlbumModel({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    required this.type,
    required this.createdBy,
    this.isFeatured = false,
    this.photoCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'coverURL': coverUrl,
    'type': type,
    'createdBy': createdBy,
    'isFeatured': isFeatured,
    'photoCount': photoCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory AlbumModel.fromJson(Map<String, dynamic> json, String id) => AlbumModel(
    id: id,
    title: json['title'],
    description: json['description'],
    coverUrl: json['coverURL'],
    type: json['type'],
    createdBy: json['createdBy'],
    isFeatured: json['isFeatured'] ?? false,
    photoCount: json['photoCount'] ?? 0,
    createdAt: json['createdAt'].toDate(),
    updatedAt: json['updatedAt'].toDate(),
  );
}
