import 'package:json_annotation/json_annotation.dart';
import 'common.dart';

part 'media.g.dart';

// Media Gallery Model
@JsonSerializable()
class MediaGallery {
  final int id;
  final int userId;
  final int? eventId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final MediaType mediaType;
  final String? caption;
  final bool isPublic;
  final bool isFeatured;
  final DateTime uploadedAt;

  MediaGallery({
    required this.id,
    required this.userId,
    this.eventId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.mediaType,
    this.caption,
    this.isPublic = true,
    this.isFeatured = false,
    required this.uploadedAt,
  });

  factory MediaGallery.fromJson(Map<String, dynamic> json) => _$MediaGalleryFromJson(json);
  Map<String, dynamic> toJson() => _$MediaGalleryToJson(this);
}

// Media Gallery Create Model
@JsonSerializable()
class MediaGalleryCreate {
  final int? eventId;
  final String fileName;
  final String fileType;
  final int fileSize;
  final MediaType mediaType;
  final String? caption;
  final bool isPublic;
  final bool isFeatured;

  MediaGalleryCreate({
    this.eventId,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.mediaType,
    this.caption,
    this.isPublic = true,
    this.isFeatured = false,
  });

  factory MediaGalleryCreate.fromJson(Map<String, dynamic> json) => _$MediaGalleryCreateFromJson(json);
  Map<String, dynamic> toJson() => _$MediaGalleryCreateToJson(this);
}

// Media Gallery Update Model
@JsonSerializable()
class MediaGalleryUpdate {
  final String? caption;
  final bool? isPublic;
  final bool? isFeatured;

  MediaGalleryUpdate({
    this.caption,
    this.isPublic,
    this.isFeatured,
  });

  factory MediaGalleryUpdate.fromJson(Map<String, dynamic> json) => _$MediaGalleryUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$MediaGalleryUpdateToJson(this);
}
