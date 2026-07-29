class BusinessModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String category;
  final String? logoUrl;
  final String? coverUrl;
  final String? contactEmail;
  final String? contactPhone;
  final String? website;
  final Map<String, String?> socialLinks;
  final String? address;
  final String? city;
  final String country;
  final bool isVerified;
  final bool isFeatured;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.category,
    this.logoUrl,
    this.coverUrl,
    this.contactEmail,
    this.contactPhone,
    this.website,
    this.socialLinks = const {},
    this.address,
    this.city,
    this.country = 'Nigeria',
    this.isVerified = false,
    this.isFeatured = false,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'ownerId': ownerId,
    'name': name,
    'description': description,
    'category': category,
    'logoURL': logoUrl,
    'coverURL': coverUrl,
    'contactEmail': contactEmail,
    'contactPhone': contactPhone,
    'website': website,
    'socialLinks': socialLinks,
    'address': address,
    'city': city,
    'country': country,
    'isVerified': isVerified,
    'isFeatured': isFeatured,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory BusinessModel.fromJson(Map<String, dynamic> json, String id) => BusinessModel(
    id: id,
    ownerId: json['ownerId'],
    name: json['name'],
    description: json['description'] ?? '',
    category: json['category'],
    logoUrl: json['logoURL'],
    coverUrl: json['coverURL'],
    contactEmail: json['contactEmail'],
    contactPhone: json['contactPhone'],
    website: json['website'],
    socialLinks: Map<String, String?>.from(json['socialLinks'] ?? {}),
    address: json['address'],
    city: json['city'],
    country: json['country'] ?? 'Nigeria',
    isVerified: json['isVerified'] ?? false,
    isFeatured: json['isFeatured'] ?? false,
    status: json['status'] ?? 'active',
    createdAt: json['createdAt'].toDate(),
    updatedAt: json['updatedAt'].toDate(),
  );
}

class JobModel {
  final String id;
  final String postedBy;
  final String? businessId;
  final String title;
  final String description;
  final String type;
  final String category;
  final String? location;
  final bool isRemote;
  final String? salary;
  final String? applicationUrl;
  final String? applicationEmail;
  final DateTime? deadline;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobModel({
    required this.id,
    required this.postedBy,
    this.businessId,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.location,
    this.isRemote = false,
    this.salary,
    this.applicationUrl,
    this.applicationEmail,
    this.deadline,
    this.status = 'open',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'postedBy': postedBy,
    'businessId': businessId,
    'title': title,
    'description': description,
    'type': type,
    'category': category,
    'location': location,
    'isRemote': isRemote,
    'salary': salary,
    'applicationURL': applicationUrl,
    'applicationEmail': applicationEmail,
    'deadline': deadline,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory JobModel.fromJson(Map<String, dynamic> json, String id) => JobModel(
    id: id,
    postedBy: json['postedBy'],
    businessId: json['businessId'],
    title: json['title'],
    description: json['description'] ?? '',
    type: json['type'],
    category: json['category'],
    location: json['location'],
    isRemote: json['isRemote'] ?? false,
    salary: json['salary'],
    applicationUrl: json['applicationURL'],
    applicationEmail: json['applicationEmail'],
    deadline: json['deadline']?.toDate(),
    status: json['status'] ?? 'open',
    createdAt: json['createdAt'].toDate(),
    updatedAt: json['updatedAt'].toDate(),
  );
}
