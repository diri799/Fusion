import 'package:json_annotation/json_annotation.dart';
import 'common.dart';

part 'event.g.dart';

// Event Model
@JsonSerializable()
class Event {
  final int id;
  final String title;
  final String description;
  final EventCategory category;
  final EventStatus status;
  @JsonKey(name: 'organizer_id')
  final int organizerId;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @JsonKey(name: 'registration_deadline')
  final DateTime? registrationDeadline;
  final String? venue;
  @JsonKey(name: 'max_participants')
  final int? maxParticipants;
  @JsonKey(name: 'registration_fee')
  final int registrationFee;
  @JsonKey(name: 'is_paid_event')
  final bool isPaidEvent;
  final String currency;
  @JsonKey(name: 'early_bird_price')
  final int? earlyBirdPrice;
  @JsonKey(name: 'early_bird_deadline')
  final DateTime? earlyBirdDeadline;
  @JsonKey(name: 'group_discount_percentage')
  final int? groupDiscountPercentage;
  @JsonKey(name: 'group_discount_min_people')
  final int? groupDiscountMinPeople;
  final String? requirements;
  @JsonKey(name: 'banner_image_url')
  final String? bannerImageUrl;
  @JsonKey(name: 'event_agenda')
  final String? eventAgenda;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  
  // Additional fields from EventWithDetails
  final Map<String, dynamic>? organizer;
  @JsonKey(name: 'registration_count')
  final int? registrationCount;
  @JsonKey(name: 'is_registered')
  final bool? isRegistered;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.organizerId,
    required this.startDate,
    required this.endDate,
    this.registrationDeadline,
    this.venue,
    this.maxParticipants,
    this.registrationFee = 0,
    this.isPaidEvent = false,
    this.currency = 'USD',
    this.earlyBirdPrice,
    this.earlyBirdDeadline,
    this.groupDiscountPercentage,
    this.groupDiscountMinPeople,
    this.requirements,
    this.bannerImageUrl,
    this.eventAgenda,
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
    this.organizer,
    this.registrationCount,
    this.isRegistered,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  // Additional properties for UI compatibility
  String get eventId => id.toString();
  DateTime get eventDate => startDate;
  String get eventTime =>
      '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}';
  String get formattedDateTime =>
      '${startDate.day}/${startDate.month}/${startDate.year} at $eventTime';
  String get formattedDate =>
      '${startDate.day}/${startDate.month}/${startDate.year}';
  String get department => 'General'; // Default department
  int get currentParticipants => 0; // Default value
  bool get canRegister =>
      status == EventStatus.published &&
      (registrationDeadline == null ||
          DateTime.now().isBefore(registrationDeadline!)) &&
      (maxParticipants == null || currentParticipants < maxParticipants!);
  String get registrationStatus => 'Available'; // Default status
  double get occupancyPercentage =>
      maxParticipants != null
          ? (currentParticipants / maxParticipants!) * 100
          : 0.0;
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isPast => endDate.isBefore(DateTime.now());
  List<String> get tags => [category.name]; // Convert category to tags
  
  // Pricing helper methods
  bool get isFree => !isPaidEvent || registrationFee == 0;
  bool get hasEarlyBirdPricing => earlyBirdPrice != null && earlyBirdDeadline != null;
  bool get isEarlyBirdActive => hasEarlyBirdPricing && DateTime.now().isBefore(earlyBirdDeadline!);
  double get currentPrice => isEarlyBirdActive ? (earlyBirdPrice! / 100.0) : (registrationFee / 100.0);
  String get displayPrice => isFree ? 'Free' : '$currency ${currentPrice.toStringAsFixed(2)}';
  bool get hasGroupDiscount => groupDiscountPercentage != null && groupDiscountMinPeople != null;
  double getGroupDiscountPrice(int quantity) {
    if (!hasGroupDiscount || quantity < groupDiscountMinPeople!) return currentPrice;
    return currentPrice * (1 - groupDiscountPercentage! / 100);
  }

  // Create method for UI compatibility
  factory Event.create({
    required int id,
    required String title,
    required String description,
    required EventCategory category,
    required EventStatus status,
    required int organizerId,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? registrationDeadline,
    String? venue,
    int? maxParticipants,
    int registrationFee = 0,
    bool isPaidEvent = false,
    String currency = 'USD',
    String? requirements,
    String? bannerImageUrl,
    String? eventAgenda,
    bool isFeatured = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Additional parameters for UI compatibility
    String? eventId,
    DateTime? eventDate,
    String? eventTime,
    String? department,
    int? currentParticipants,
    List<String>? tags,
  }) {
    return Event(
      id: id,
      title: title,
      description: description,
      category: category,
      status: status,
      organizerId: organizerId,
      startDate: startDate,
      endDate: endDate,
      registrationDeadline: registrationDeadline,
      venue: venue,
      maxParticipants: maxParticipants,
      registrationFee: registrationFee,
      isPaidEvent: isPaidEvent,
      currency: currency,
      requirements: requirements,
      bannerImageUrl: bannerImageUrl,
      eventAgenda: eventAgenda,
      isFeatured: isFeatured,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  // CopyWith method for UI compatibility
  Event copyWith({
    int? id,
    String? title,
    String? description,
    EventCategory? category,
    EventStatus? status,
    int? organizerId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationDeadline,
    String? venue,
    int? maxParticipants,
    int? registrationFee,
    String? requirements,
    String? bannerImageUrl,
    String? eventAgenda,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Additional parameters for UI compatibility
    String? eventId,
    DateTime? eventDate,
    String? eventTime,
    String? department,
    int? currentParticipants,
    List<String>? tags,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      organizerId: organizerId ?? this.organizerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      venue: venue ?? this.venue,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      registrationFee: registrationFee ?? this.registrationFee,
      requirements: requirements ?? this.requirements,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      eventAgenda: eventAgenda ?? this.eventAgenda,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // FromMap method for database compatibility
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: int.tryParse(map['id']?.toString() ?? map['event_id']?.toString() ?? '0') ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: EventCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => EventCategory.academic,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EventStatus.draft,
      ),
      organizerId: int.tryParse(map['organizer_id']?.toString() ?? '0') ?? 0,
      startDate: DateTime.tryParse(map['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['end_date'] ?? '') ?? DateTime.now(),
      registrationDeadline:
          map['registration_deadline'] != null
              ? DateTime.tryParse(map['registration_deadline'])
              : null,
      venue: map['venue'],
      maxParticipants: map['max_participants'],
      registrationFee: map['registration_fee'] ?? 0,
      requirements: map['requirements'],
      bannerImageUrl: map['banner_image_url'],
      eventAgenda: map['event_agenda'],
      isFeatured: map['is_featured'] == 1 || map['is_featured'] == true,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt:
          map['updated_at'] != null
              ? DateTime.tryParse(map['updated_at'])
              : null,
    );
  }

  // ToMap method for database compatibility
  Map<String, dynamic> toMap() {
    return {
      'event_id': id.toString(), // Convert to string to match database schema
      'title': title,
      'description': description,
      'category': category.name,
      'status': status.name,
      'organizer_id': organizerId.toString(), // Convert to string to match database schema
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'venue': venue,
      'max_participants': maxParticipants,
      'registration_fee': registrationFee,
      'requirements': requirements,
      'banner_image_url': bannerImageUrl,
      'event_agenda': eventAgenda,
      'is_featured': isFeatured ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Event Create Model
@JsonSerializable()
class EventCreate {
  final String title;
  final String description;
  final EventCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? registrationDeadline;
  final String? venue;
  final int? maxParticipants;
  final int registrationFee;
  final bool isPaidEvent;
  final String currency;
  final String? requirements;
  final String? bannerImageUrl;
  final String? eventAgenda;
  final bool isFeatured;

  EventCreate({
    required this.title,
    required this.description,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.registrationDeadline,
    this.venue,
    this.maxParticipants,
    this.registrationFee = 0,
    this.isPaidEvent = false,
    this.currency = 'USD',
    this.requirements,
    this.bannerImageUrl,
    this.eventAgenda,
    this.isFeatured = false,
  });

  factory EventCreate.fromJson(Map<String, dynamic> json) =>
      _$EventCreateFromJson(json);
  
  Map<String, dynamic> toJson() {
    // Map frontend categories to backend categories
    String backendCategory;
    switch (category) {
      case EventCategory.academic:
        backendCategory = 'other'; // Map academic to other (not supported by backend)
        break;
      default:
        backendCategory = category.name; // All other categories are supported by backend
    }
    
    return {
      'title': title,
      'description': description,
      'category': backendCategory,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'venue': venue,
      'max_participants': maxParticipants,
      'registration_fee': registrationFee,
      'is_paid_event': isPaidEvent,
      'currency': currency,
      'requirements': requirements,
      'banner_image_url': bannerImageUrl,
      'event_agenda': eventAgenda,
      'is_featured': isFeatured,
    };
  }
}

// Event Update Model
@JsonSerializable()
class EventUpdate {
  final String? title;
  final String? description;
  final EventCategory? category;
  final EventStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? registrationDeadline;
  final String? venue;
  final int? maxParticipants;
  final int? registrationFee;
  final String? requirements;
  final String? bannerImageUrl;
  final String? eventAgenda;
  final bool? isFeatured;

  EventUpdate({
    this.title,
    this.description,
    this.category,
    this.status,
    this.startDate,
    this.endDate,
    this.registrationDeadline,
    this.venue,
    this.maxParticipants,
    this.registrationFee,
    this.requirements,
    this.bannerImageUrl,
    this.eventAgenda,
    this.isFeatured,
  });

  factory EventUpdate.fromJson(Map<String, dynamic> json) =>
      _$EventUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$EventUpdateToJson(this);
}
