// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaGallery _$MediaGalleryFromJson(Map<String, dynamic> json) => MediaGallery(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  eventId: (json['eventId'] as num?)?.toInt(),
  fileName: json['fileName'] as String,
  fileUrl: json['fileUrl'] as String,
  fileType: json['fileType'] as String,
  fileSize: (json['fileSize'] as num).toInt(),
  mediaType: $enumDecode(_$MediaTypeEnumMap, json['mediaType']),
  caption: json['caption'] as String?,
  isPublic: json['isPublic'] as bool? ?? true,
  isFeatured: json['isFeatured'] as bool? ?? false,
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
);

Map<String, dynamic> _$MediaGalleryToJson(MediaGallery instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'eventId': instance.eventId,
      'fileName': instance.fileName,
      'fileUrl': instance.fileUrl,
      'fileType': instance.fileType,
      'fileSize': instance.fileSize,
      'mediaType': _$MediaTypeEnumMap[instance.mediaType]!,
      'caption': instance.caption,
      'isPublic': instance.isPublic,
      'isFeatured': instance.isFeatured,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
    };

const _$MediaTypeEnumMap = {
  MediaType.image: 'image',
  MediaType.video: 'video',
  MediaType.document: 'document',
  MediaType.audio: 'audio',
};

MediaGalleryCreate _$MediaGalleryCreateFromJson(Map<String, dynamic> json) =>
    MediaGalleryCreate(
      eventId: (json['eventId'] as num?)?.toInt(),
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      mediaType: $enumDecode(_$MediaTypeEnumMap, json['mediaType']),
      caption: json['caption'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );

Map<String, dynamic> _$MediaGalleryCreateToJson(MediaGalleryCreate instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'fileName': instance.fileName,
      'fileType': instance.fileType,
      'fileSize': instance.fileSize,
      'mediaType': _$MediaTypeEnumMap[instance.mediaType]!,
      'caption': instance.caption,
      'isPublic': instance.isPublic,
      'isFeatured': instance.isFeatured,
    };

MediaGalleryUpdate _$MediaGalleryUpdateFromJson(Map<String, dynamic> json) =>
    MediaGalleryUpdate(
      caption: json['caption'] as String?,
      isPublic: json['isPublic'] as bool?,
      isFeatured: json['isFeatured'] as bool?,
    );

Map<String, dynamic> _$MediaGalleryUpdateToJson(MediaGalleryUpdate instance) =>
    <String, dynamic>{
      'caption': instance.caption,
      'isPublic': instance.isPublic,
      'isFeatured': instance.isFeatured,
    };
