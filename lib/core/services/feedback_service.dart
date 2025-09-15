import 'api_service.dart';
import '../constants/api_constants.dart';
import '../../data/models/feedback.dart';
import '../../data/models/common.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final ApiService _apiService = ApiService.instance;

  // Get feedback for a specific event
  Future<PaginatedResponse<Feedback>> getEventFeedback(int eventId, {int page = 1, int size = 10}) async {
    try {
      // Since ApiService doesn't have getEventFeedback, we'll get all feedback and filter
      // This is a temporary solution - ideally the backend should support this endpoint
      final response = await _apiService.getMyFeedback();
      
      // Convert to list of feedback items and filter by eventId
      final allFeedback = response.map((json) => Feedback.fromJson(json as Map<String, dynamic>)).toList();
      final eventFeedback = allFeedback.where((feedback) => feedback.eventId == eventId).toList();
      
      // Apply pagination
      final startIndex = (page - 1) * size;
      final endIndex = startIndex + size;
      final paginatedItems = eventFeedback.length > startIndex 
          ? eventFeedback.sublist(startIndex, endIndex.clamp(0, eventFeedback.length))
          : <Feedback>[];
      
      return PaginatedResponse<Feedback>(
        items: paginatedItems,
        total: eventFeedback.length,
        page: page,
        size: size,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch event feedback: $e');
    }
  }

  // Submit feedback for an event
  Future<Feedback> submitFeedback(FeedbackCreate feedbackData) async {
    try {
      final response = await _apiService.submitFeedback(
        eventId: feedbackData.eventId,
        rating: feedbackData.rating.index + 1, // Convert enum to int (1-5)
        comment: feedbackData.comment ?? '',
      );
      return Feedback.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to submit feedback: $e');
    }
  }

  // Update feedback
  Future<Feedback> updateFeedback(int id, FeedbackUpdate feedbackData) async {
    try {
      // Since ApiService doesn't have updateFeedback, we'll need to implement this
      // For now, we'll throw an exception indicating this feature needs backend support
      throw ApiException('Update feedback feature requires backend support. Please contact administrator.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update feedback: $e');
    }
  }

  // Delete feedback
  Future<void> deleteFeedback(int id) async {
    try {
      // Since ApiService doesn't have deleteFeedback, we'll need to implement this
      // For now, we'll throw an exception indicating this feature needs backend support
      throw ApiException('Delete feedback feature requires backend support. Please contact administrator.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to delete feedback: $e');
    }
  }

  // Get my feedback
  Future<PaginatedResponse<Feedback>> getMyFeedback({int page = 1, int size = 10}) async {
    try {
      final response = await _apiService.getMyFeedback();
      
      // Convert response to list of Feedback objects
      final items = response.map((json) => Feedback.fromJson(json as Map<String, dynamic>)).toList();
      
      // Apply pagination
      final startIndex = (page - 1) * size;
      final endIndex = startIndex + size;
      final paginatedItems = items.length > startIndex 
          ? items.sublist(startIndex, endIndex.clamp(0, items.length))
          : <Feedback>[];
      
      return PaginatedResponse<Feedback>(
        items: paginatedItems,
        total: items.length,
        page: page,
        size: size,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch my feedback: $e');
    }
  }
}
