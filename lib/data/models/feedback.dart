import 'package:json_annotation/json_annotation.dart';
import 'common.dart';

part 'feedback.g.dart';

// Feedback Model
@JsonSerializable()
class Feedback {
  final int id;
  final int userId;
  final int eventId;
  final FeedbackRating rating;
  final String? comment;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Feedback({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.rating,
    this.comment,
    this.isAnonymous = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) => _$FeedbackFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackToJson(this);
}

// Feedback Create Model
@JsonSerializable()
class FeedbackCreate {
  final int eventId;
  final FeedbackRating rating;
  final String? comment;
  final bool isAnonymous;

  FeedbackCreate({
    required this.eventId,
    required this.rating,
    this.comment,
    this.isAnonymous = false,
  });

  factory FeedbackCreate.fromJson(Map<String, dynamic> json) => _$FeedbackCreateFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackCreateToJson(this);
}

// Feedback Update Model
@JsonSerializable()
class FeedbackUpdate {
  final FeedbackRating? rating;
  final String? comment;
  final bool? isAnonymous;

  FeedbackUpdate({
    this.rating,
    this.comment,
    this.isAnonymous,
  });

  factory FeedbackUpdate.fromJson(Map<String, dynamic> json) => _$FeedbackUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackUpdateToJson(this);
}
