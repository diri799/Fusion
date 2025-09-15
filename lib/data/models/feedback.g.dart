// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feedback _$FeedbackFromJson(Map<String, dynamic> json) => Feedback(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  eventId: (json['eventId'] as num).toInt(),
  rating: $enumDecode(_$FeedbackRatingEnumMap, json['rating']),
  comment: json['comment'] as String?,
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FeedbackToJson(Feedback instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'eventId': instance.eventId,
  'rating': _$FeedbackRatingEnumMap[instance.rating]!,
  'comment': instance.comment,
  'isAnonymous': instance.isAnonymous,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$FeedbackRatingEnumMap = {
  FeedbackRating.veryPoor: 'very_poor',
  FeedbackRating.poor: 'poor',
  FeedbackRating.average: 'average',
  FeedbackRating.good: 'good',
  FeedbackRating.excellent: 'excellent',
};

FeedbackCreate _$FeedbackCreateFromJson(Map<String, dynamic> json) =>
    FeedbackCreate(
      eventId: (json['eventId'] as num).toInt(),
      rating: $enumDecode(_$FeedbackRatingEnumMap, json['rating']),
      comment: json['comment'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );

Map<String, dynamic> _$FeedbackCreateToJson(FeedbackCreate instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'rating': _$FeedbackRatingEnumMap[instance.rating]!,
      'comment': instance.comment,
      'isAnonymous': instance.isAnonymous,
    };

FeedbackUpdate _$FeedbackUpdateFromJson(Map<String, dynamic> json) =>
    FeedbackUpdate(
      rating: $enumDecodeNullable(_$FeedbackRatingEnumMap, json['rating']),
      comment: json['comment'] as String?,
      isAnonymous: json['isAnonymous'] as bool?,
    );

Map<String, dynamic> _$FeedbackUpdateToJson(FeedbackUpdate instance) =>
    <String, dynamic>{
      'rating': _$FeedbackRatingEnumMap[instance.rating],
      'comment': instance.comment,
      'isAnonymous': instance.isAnonymous,
    };
