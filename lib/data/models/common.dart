import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

// User Role Enum
enum UserRole {
  @JsonValue('student')
  student,
  @JsonValue('organizer')
  organizer,
  @JsonValue('admin')
  admin,
}

// Event Category Enum
enum EventCategory {
  @JsonValue('academic')
  academic,
  @JsonValue('cultural')
  cultural,
  @JsonValue('sports')
  sports,
  @JsonValue('technical')
  technical,
  @JsonValue('social')
  social,
  @JsonValue('workshop')
  workshop,
  @JsonValue('seminar')
  seminar,
  @JsonValue('conference')
  conference,
  @JsonValue('other')
  other,
}

// Event Status Enum
enum EventStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('published')
  published,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}

// Registration Status Enum
enum RegistrationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('attended')
  attended,
  @JsonValue('no_show')
  noShow,
}

// Feedback Rating Enum
enum FeedbackRating {
  @JsonValue('very_poor')
  veryPoor,
  @JsonValue('poor')
  poor,
  @JsonValue('average')
  average,
  @JsonValue('good')
  good,
  @JsonValue('excellent')
  excellent,
}

// Media Type Enum
enum MediaType {
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
  @JsonValue('document')
  document,
  @JsonValue('audio')
  audio,
}

// Certificate Type Enum
enum CertificateType {
  @JsonValue('participation')
  participation,
  @JsonValue('achievement')
  achievement,
  @JsonValue('completion')
  completion,
}

// Extension for enums to provide toJson functionality
extension EnumToJson on Enum {
  String toJson() => name;
}

// Extension for EventStatus to provide display name
extension EventStatusExtension on EventStatus {
  String get displayName {
    switch (this) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.published:
        return 'Published';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
      case EventStatus.pending:
        return 'Pending';
      case EventStatus.approved:
        return 'Approved';
      case EventStatus.rejected:
        return 'Rejected';
    }
  }
}

// Extension for EventCategory to provide display name
extension EventCategoryExtension on EventCategory {
  String get displayName {
    switch (this) {
      case EventCategory.academic:
        return 'Academic';
      case EventCategory.cultural:
        return 'Cultural';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.technical:
        return 'Technical';
      case EventCategory.social:
        return 'Social';
      case EventCategory.workshop:
        return 'Workshop';
      case EventCategory.seminar:
        return 'Seminar';
      case EventCategory.conference:
        return 'Conference';
      case EventCategory.other:
        return 'Other';
    }
  }
}

// Event Status Filter enum for UI
enum EventStatusFilter {
  all,
  upcoming,
  ongoing,
  completed,
  draft,
  published,
  cancelled,
}

// Event Status Enum (alias for EventStatus)
typedef EventStatusEnum = EventStatus;

// Pagination Model
@JsonSerializable()
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) =>
      _$PaginationInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationInfoToJson(this);
}

// Simple API Response Model
@JsonSerializable()
class ApiResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? errors;

  ApiResponse({required this.success, this.message, this.data, this.errors});

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}

// Generic Paginated Response Model
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int size;
  final T? data; // For single item responses

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    this.data,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
