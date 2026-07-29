class ProfileModel {
  final String uid;
  final String fullName;
  final String? nickname;
  final String? matricNumber;
  final String department;
  final String faculty;
  final int admissionYear;
  final int graduationYear;
  final String? phone;
  final String email;
  final String? currentAddress;
  final String? city;
  final String country;
  final String? occupation;
  final String? employer;
  final String? business;
  final List<String> skills;
  final String? bio;
  final Map<String, String?> socialLinks;
  final String? photoUrl;
  final String? coverUrl;
  final String? maritalStatus;
  final bool isExecutive;
  final bool isCommitteeMember;
  final List<String> committeeRoles;
  final String visibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.uid,
    required this.fullName,
    this.nickname,
    this.matricNumber,
    required this.department,
    required this.faculty,
    required this.admissionYear,
    required this.graduationYear,
    this.phone,
    required this.email,
    this.currentAddress,
    this.city,
    this.country = 'Nigeria',
    this.occupation,
    this.employer,
    this.business,
    this.skills = const [],
    this.bio,
    this.socialLinks = const {},
    this.photoUrl,
    this.coverUrl,
    this.maritalStatus,
    this.isExecutive = false,
    this.isCommitteeMember = false,
    this.committeeRoles = const [],
    this.visibility = 'members_only',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'fullName': fullName,
    'nickname': nickname,
    'matricNumber': matricNumber,
    'department': department,
    'faculty': faculty,
    'admissionYear': admissionYear,
    'graduationYear': graduationYear,
    'phone': phone,
    'email': email,
    'currentAddress': currentAddress,
    'city': city,
    'country': country,
    'occupation': occupation,
    'employer': employer,
    'business': business,
    'skills': skills,
    'bio': bio,
    'socialLinks': socialLinks,
    'photoURL': photoUrl,
    'coverURL': coverUrl,
    'maritalStatus': maritalStatus,
    'isExecutive': isExecutive,
    'isCommitteeMember': isCommitteeMember,
    'committeeRoles': committeeRoles,
    'visibility': visibility,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    uid: json['uid'],
    fullName: json['fullName'],
    nickname: json['nickname'],
    matricNumber: json['matricNumber'],
    department: json['department'],
    faculty: json['faculty'],
    admissionYear: json['admissionYear'],
    graduationYear: json['graduationYear'],
    phone: json['phone'],
    email: json['email'],
    currentAddress: json['currentAddress'],
    city: json['city'],
    country: json['country'] ?? 'Nigeria',
    occupation: json['occupation'],
    employer: json['employer'],
    business: json['business'],
    skills: List<String>.from(json['skills'] ?? []),
    bio: json['bio'],
    socialLinks: Map<String, String?>.from(json['socialLinks'] ?? {}),
    photoUrl: json['photoURL'],
    coverUrl: json['coverURL'],
    maritalStatus: json['maritalStatus'],
    isExecutive: json['isExecutive'] ?? false,
    isCommitteeMember: json['isCommitteeMember'] ?? false,
    committeeRoles: List<String>.from(json['committeeRoles'] ?? []),
    visibility: json['visibility'] ?? 'members_only',
    createdAt: json['createdAt'].toDate(),
    updatedAt: json['updatedAt'].toDate(),
  );
}
