class EventModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String? bannerUrl;
  final DateTime startDate;
  final DateTime endDate;
  final EventLocation location;
  final String organizerId;
  final int? maxAttendees;
  final DateTime? rsvpDeadline;
  final double? ticketPrice;
  final String? currency;
  final String status;
  final int attendeeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.bannerUrl,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.organizerId,
    this.maxAttendees,
    this.rsvpDeadline,
    this.ticketPrice,
    this.currency,
    this.status = 'draft',
    this.attendeeCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'type': type,
    'bannerURL': bannerUrl,
    'startDate': startDate,
    'endDate': endDate,
    'location': location.toJson(),
    'organizerId': organizerId,
    'maxAttendees': maxAttendees,
    'rsvpDeadline': rsvpDeadline,
    'ticketPrice': ticketPrice,
    'currency': currency,
    'status': status,
    'attendeeCount': attendeeCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory EventModel.fromJson(Map<String, dynamic> json, String id) => EventModel(
    id: id,
    title: json['title'],
    description: json['description'] ?? '',
    type: json['type'],
    bannerUrl: json['bannerURL'],
    startDate: json['startDate'].toDate(),
    endDate: json['endDate'].toDate(),
    location: EventLocation.fromJson(json['location']),
    organizerId: json['organizerId'],
    maxAttendees: json['maxAttendees'],
    rsvpDeadline: json['rsvpDeadline']?.toDate(),
    ticketPrice: (json['ticketPrice'] as num?)?.toDouble(),
    currency: json['currency'],
    status: json['status'] ?? 'draft',
    attendeeCount: json['attendeeCount'] ?? 0,
    createdAt: json['createdAt'].toDate(),
    updatedAt: json['updatedAt'].toDate(),
  );
}

class EventLocation {
  final String name;
  final String? address;
  final double? lat;
  final double? lng;
  final bool isVirtual;
  final String? meetingLink;

  EventLocation({
    required this.name,
    this.address,
    this.lat,
    this.lng,
    this.isVirtual = false,
    this.meetingLink,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'lat': lat,
    'lng': lng,
    'isVirtual': isVirtual,
    'meetingLink': meetingLink,
  };

  factory EventLocation.fromJson(Map<String, dynamic> json) => EventLocation(
    name: json['name'],
    address: json['address'],
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    isVirtual: json['isVirtual'] ?? false,
    meetingLink: json['meetingLink'],
  );
}
