class UserModel {
  final String uid;
  final String email;
  final String? phone;
  final String displayName;
  final String? photoUrl;
  final String role;
  final String status;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.phone,
    required this.displayName,
    this.photoUrl,
    this.role = 'visitor',
    this.status = 'pending',
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
    required this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'phone': phone,
    'displayName': displayName,
    'photoURL': photoUrl,
    'role': role,
    'status': status,
    'isApproved': isApproved,
    'approvedBy': approvedBy,
    'approvedAt': approvedAt,
    'lastLoginAt': lastLoginAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'],
    email: json['email'],
    phone: json['phone'],
    displayName: json['displayName'],
    photoUrl: json['photoURL'],
    role: json['role'] ?? 'visitor',
    status: json['status'] ?? 'pending',
    isApproved: json['isApproved'] ?? false,
    approvedBy: json['approvedBy'],
    approvedAt: json['approvedAt']?.toDate(),
    lastLoginAt: json['lastLoginAt'].toDate(),
    createdAt: json['createdAt'].toDate(),
    updatedAt: json['updatedAt'].toDate(),
  );
}
