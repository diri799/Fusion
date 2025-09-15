import 'dart:io';
import "dart:convert";
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../constants/api_constants.dart';
import '../../data/models/media.dart';
import '../../data/models/common.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final ApiService _apiService = ApiService.instance;

  // Get media gallery items for an event
  Future<PaginatedResponse<MediaGallery>> getEventMedia(int eventId, {int page = 1, int size = 10}) async {
    try {
      // Since ApiService doesn't have getEventMedia, we'll get all media and filter
      final response = await _apiService.getMediaGallery();
      
      // Convert to list of media items and filter by eventId
      final allMedia = response.map((json) => MediaGallery.fromJson(json as Map<String, dynamic>)).toList();
      final eventMedia = allMedia.where((media) => media.eventId == eventId).toList();
      
      // Apply pagination
      final startIndex = (page - 1) * size;
      final endIndex = startIndex + size;
      final paginatedItems = eventMedia.length > startIndex 
          ? eventMedia.sublist(startIndex, endIndex.clamp(0, eventMedia.length))
          : <MediaGallery>[];
      
      return PaginatedResponse<MediaGallery>(
        items: paginatedItems,
        total: eventMedia.length,
        page: page,
        size: size,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch event media: $e');
    }
  }

  // Upload media file
  Future<MediaGallery> uploadMedia({
    required File file,
    required int eventId,
    required MediaType type,
    String? caption,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.apiBaseUrl}${ApiConstants.mediaUploadEndpoint}'),
      );

      // Add authorization header
      final token = await _apiService.accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      // Add form fields
      request.fields['event_id'] = eventId.toString();
      request.fields['type'] = type.toJson();
      if (caption != null) request.fields['caption'] = caption;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return MediaGallery.fromJson(responseData);
      } else {
        throw ApiException('Upload failed: ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to upload media: $e');
    }
  }

  // Get all media items
  Future<PaginatedResponse<MediaGallery>> getAllMedia({int page = 1, int size = 10}) async {
    try {
      final response = await _apiService.getMediaGallery();
      
      // Convert response to list of MediaGallery objects
      final items = response.map((json) => MediaGallery.fromJson(json as Map<String, dynamic>)).toList();
      
      // Apply pagination
      final startIndex = (page - 1) * size;
      final endIndex = startIndex + size;
      final paginatedItems = items.length > startIndex 
          ? items.sublist(startIndex, endIndex.clamp(0, items.length))
          : <MediaGallery>[];
      
      return PaginatedResponse<MediaGallery>(
        items: paginatedItems,
        total: items.length,
        page: page,
        size: size,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch media: $e');
    }
  }

  // Get media by type
  Future<PaginatedResponse<MediaGallery>> getMediaByType(MediaType type, {int page = 1, int size = 10}) async {
    try {
      // Since ApiService doesn't have getMediaByType, we'll get all media and filter
      final response = await _apiService.getMediaGallery();
      
      // Convert to list of media items and filter by type
      final allMedia = response.map((json) => MediaGallery.fromJson(json as Map<String, dynamic>)).toList();
      final filteredMedia = allMedia.where((media) => media.mediaType == type).toList();
      
      // Apply pagination
      final startIndex = (page - 1) * size;
      final endIndex = startIndex + size;
      final paginatedItems = filteredMedia.length > startIndex 
          ? filteredMedia.sublist(startIndex, endIndex.clamp(0, filteredMedia.length))
          : <MediaGallery>[];
      
      return PaginatedResponse<MediaGallery>(
        items: paginatedItems,
        total: filteredMedia.length,
        page: page,
        size: size,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch media by type: $e');
    }
  }

  // Update media item
  Future<MediaGallery> updateMedia(int id, MediaGalleryUpdate mediaData) async {
    try {
      // Since ApiService doesn't have updateMedia, we'll need to implement this
      // For now, we'll throw an exception indicating this feature needs backend support
      throw ApiException('Update media feature requires backend support. Please contact administrator.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update media: $e');
    }
  }

  // Delete media item
  Future<void> deleteMedia(int id) async {
    try {
      // Since ApiService doesn't have deleteMedia, we'll need to implement this
      // For now, we'll throw an exception indicating this feature needs backend support
      throw ApiException('Delete media feature requires backend support. Please contact administrator.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to delete media: $e');
    }
  }

  // Helper to get allowed file extensions based on MediaType
  List<String> getAllowedExtensions(MediaType type) {
    switch (type) {
      case MediaType.image:
        return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
      case MediaType.video:
        return ['mp4', 'mov', 'avi', 'mkv', 'webm'];
      case MediaType.document:
        return ['pdf', 'doc', 'docx', 'txt'];
      case MediaType.audio:
        return []; // Allow any for 'other' or specify common ones
    }
  }

  // Validate file type
  bool isValidFileType(File file, MediaType type) {
    final extension = file.path.split('.').last.toLowerCase();
    return getAllowedExtensions(type).contains(extension);
  }
}
