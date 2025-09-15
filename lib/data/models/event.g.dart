// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$EventCategoryEnumMap, json['category']),
  status: $enumDecode(_$EventStatusEnumMap, json['status']),
  organizerId: (json['organizer_id'] as num).toInt(),
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: DateTime.parse(json['end_date'] as String),
  registrationDeadline:
      json['registration_deadline'] == null
          ? null
          : DateTime.parse(json['registration_deadline'] as String),
  venue: json['venue'] as String?,
  maxParticipants: (json['max_participants'] as num?)?.toInt(),
  registrationFee: (json['registration_fee'] as num?)?.toInt() ?? 0,
  isPaidEvent: json['is_paid_event'] as bool? ?? false,
  currency: json['currency'] as String? ?? 'USD',
  earlyBirdPrice: (json['early_bird_price'] as num?)?.toInt(),
  earlyBirdDeadline:
      json['early_bird_deadline'] == null
          ? null
          : DateTime.parse(json['early_bird_deadline'] as String),
  groupDiscountPercentage: (json['group_discount_percentage'] as num?)?.toInt(),
  groupDiscountMinPeople: (json['group_discount_min_people'] as num?)?.toInt(),
  requirements: json['requirements'] as String?,
  bannerImageUrl: json['banner_image_url'] as String?,
  eventAgenda: json['event_agenda'] as String?,
  isFeatured: json['is_featured'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  organizer: json['organizer'] as Map<String, dynamic>?,
  registrationCount: (json['registration_count'] as num?)?.toInt(),
  isRegistered: json['is_registered'] as bool?,
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': _$EventCategoryEnumMap[instance.category]!,
  'status': _$EventStatusEnumMap[instance.status]!,
  'organizer_id': instance.organizerId,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate.toIso8601String(),
  'registration_deadline': instance.registrationDeadline?.toIso8601String(),
  'venue': instance.venue,
  'max_participants': instance.maxParticipants,
  'registration_fee': instance.registrationFee,
  'is_paid_event': instance.isPaidEvent,
  'currency': instance.currency,
  'early_bird_price': instance.earlyBirdPrice,
  'early_bird_deadline': instance.earlyBirdDeadline?.toIso8601String(),
  'group_discount_percentage': instance.groupDiscountPercentage,
  'group_discount_min_people': instance.groupDiscountMinPeople,
  'requirements': instance.requirements,
  'banner_image_url': instance.bannerImageUrl,
  'event_agenda': instance.eventAgenda,
  'is_featured': instance.isFeatured,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'organizer': instance.organizer,
  'registration_count': instance.registrationCount,
  'is_registered': instance.isRegistered,
};

const _$EventCategoryEnumMap = {
  EventCategory.academic: 'academic',
  EventCategory.cultural: 'cultural',
  EventCategory.sports: 'sports',
  EventCategory.technical: 'technical',
  EventCategory.social: 'social',
  EventCategory.workshop: 'workshop',
  EventCategory.seminar: 'seminar',
  EventCategory.conference: 'conference',
  EventCategory.other: 'other',
};

const _$EventStatusEnumMap = {
  EventStatus.draft: 'draft',
  EventStatus.published: 'published',
  EventStatus.ongoing: 'ongoing',
  EventStatus.completed: 'completed',
  EventStatus.cancelled: 'cancelled',
  EventStatus.pending: 'pending',
  EventStatus.approved: 'approved',
  EventStatus.rejected: 'rejected',
};

EventCreate _$EventCreateFromJson(Map<String, dynamic> json) => EventCreate(
  title: json['title'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$EventCategoryEnumMap, json['category']),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  registrationDeadline:
      json['registrationDeadline'] == null
          ? null
          : DateTime.parse(json['registrationDeadline'] as String),
  venue: json['venue'] as String?,
  maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
  registrationFee: (json['registrationFee'] as num?)?.toInt() ?? 0,
  isPaidEvent: json['isPaidEvent'] as bool? ?? false,
  currency: json['currency'] as String? ?? 'USD',
  requirements: json['requirements'] as String?,
  bannerImageUrl: json['bannerImageUrl'] as String?,
  eventAgenda: json['eventAgenda'] as String?,
  isFeatured: json['isFeatured'] as bool? ?? false,
);

Map<String, dynamic> _$EventCreateToJson(EventCreate instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': _$EventCategoryEnumMap[instance.category]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'registrationDeadline': instance.registrationDeadline?.toIso8601String(),
      'venue': instance.venue,
      'maxParticipants': instance.maxParticipants,
      'registrationFee': instance.registrationFee,
      'isPaidEvent': instance.isPaidEvent,
      'currency': instance.currency,
      'requirements': instance.requirements,
      'bannerImageUrl': instance.bannerImageUrl,
      'eventAgenda': instance.eventAgenda,
      'isFeatured': instance.isFeatured,
    };

EventUpdate _$EventUpdateFromJson(Map<String, dynamic> json) => EventUpdate(
  title: json['title'] as String?,
  description: json['description'] as String?,
  category: $enumDecodeNullable(_$EventCategoryEnumMap, json['category']),
  status: $enumDecodeNullable(_$EventStatusEnumMap, json['status']),
  startDate:
      json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
  endDate:
      json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
  registrationDeadline:
      json['registrationDeadline'] == null
          ? null
          : DateTime.parse(json['registrationDeadline'] as String),
  venue: json['venue'] as String?,
  maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
  registrationFee: (json['registrationFee'] as num?)?.toInt(),
  requirements: json['requirements'] as String?,
  bannerImageUrl: json['bannerImageUrl'] as String?,
  eventAgenda: json['eventAgenda'] as String?,
  isFeatured: json['isFeatured'] as bool?,
);

Map<String, dynamic> _$EventUpdateToJson(EventUpdate instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': _$EventCategoryEnumMap[instance.category],
      'status': _$EventStatusEnumMap[instance.status],
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'registrationDeadline': instance.registrationDeadline?.toIso8601String(),
      'venue': instance.venue,
      'maxParticipants': instance.maxParticipants,
      'registrationFee': instance.registrationFee,
      'requirements': instance.requirements,
      'bannerImageUrl': instance.bannerImageUrl,
      'eventAgenda': instance.eventAgenda,
      'isFeatured': instance.isFeatured,
    };
