import 'api_service.dart';
import '../constants/api_constants.dart';
import '../../data/models/event.dart';
import '../../data/models/common.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final ApiService _apiService = ApiService.instance;

  // Get all events with optional filters and pagination
  Future<PaginatedResponse<Event>> getEvents({
    String? query,
    EventCategory? category,
    EventStatus? status,
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _apiService.getEvents(
        page: page,
        size: size,
        category: category?.toJson(),
        status: status?.toJson(),
      );

      // Handle paginated response - API returns 'events' field, not 'items'
      if (response['events'] != null) {
        final items = (response['events'] as List)
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return PaginatedResponse<Event>(
          items: items,
          total: response['total'] ?? 0,
          page: response['page'] ?? page,
          size: response['size'] ?? size,
        );
      } else {
        // Handle single item response
        final event = Event.fromJson(response);
        return PaginatedResponse<Event>(
          items: [event],
          total: 1,
          page: 1,
          size: 1,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch events: $e');
    }
  }

  // Get event by ID
  Future<Event> getEventById(int id) async {
    try {
      final response = await _apiService.getEvent(id);
      return Event.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch event: $e');
    }
  }

  // Search events
  Future<PaginatedResponse<Event>> searchEvents({
    required String query,
    EventCategory? category,
    EventStatus? status,
    int page = 1,
    int size = 10,
  }) async {
    try {
      // Use getEvents with query parameter since search endpoint may not exist
      final response = await _apiService.getEvents(
        page: page,
        size: size,
        category: category?.toJson(),
        status: status?.toJson(),
      );

      if (response['events'] != null) {
        final items = (response['events'] as List)
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Filter by query if provided
        final filteredItems = query.isNotEmpty
            ? items.where((event) => 
                event.title.toLowerCase().contains(query.toLowerCase()) ||
                event.description.toLowerCase().contains(query.toLowerCase())
              ).toList()
            : items;
        
        return PaginatedResponse<Event>(
          items: filteredItems,
          total: filteredItems.length,
          page: page,
          size: size,
        );
      } else {
        return PaginatedResponse<Event>(
          items: [],
          total: 0,
          page: page,
          size: size,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to search events: $e');
    }
  }

  // Get events by category
  Future<PaginatedResponse<Event>> getEventsByCategory(
    EventCategory category, {
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _apiService.getEvents(
        page: page,
        size: size,
        category: category.toJson(),
      );

      if (response['events'] != null) {
        final items = (response['events'] as List)
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return PaginatedResponse<Event>(
          items: items,
          total: response['total'] ?? 0,
          page: response['page'] ?? page,
          size: response['size'] ?? size,
        );
      } else {
        return PaginatedResponse<Event>(
          items: [],
          total: 0,
          page: page,
          size: size,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch events by category: $e');
    }
  }

  // Get featured events
  Future<PaginatedResponse<Event>> getFeaturedEvents({int page = 1, int size = 10}) async {
    try {
      final response = await _apiService.getEvents(
        page: page,
        size: size,
      );

      if (response['items'] != null) {
        final allItems = (response['items'] as List)
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Filter for featured events
        final featuredItems = allItems.where((event) => event.isFeatured).toList();
        
        return PaginatedResponse<Event>(
          items: featuredItems,
          total: featuredItems.length,
          page: page,
          size: size,
        );
      } else {
        return PaginatedResponse<Event>(
          items: [],
          total: 0,
          page: page,
          size: size,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch featured events: $e');
    }
  }

  // Get upcoming events
  Future<PaginatedResponse<Event>> getUpcomingEvents({int page = 1, int size = 10}) async {
    try {
      final response = await _apiService.getEvents(
        page: page,
        size: size,
      );

      if (response['items'] != null) {
        final allItems = (response['items'] as List)
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Filter for upcoming events
        final now = DateTime.now();
        final upcomingItems = allItems.where((event) => event.startDate.isAfter(now)).toList();
        
        return PaginatedResponse<Event>(
          items: upcomingItems,
          total: upcomingItems.length,
          page: page,
          size: size,
        );
      } else {
        return PaginatedResponse<Event>(
          items: [],
          total: 0,
          page: page,
          size: size,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch upcoming events: $e');
    }
  }

  // Create event (organizer/admin only)
  Future<Event> createEvent(EventCreate eventData) async {
    try {
      final response = await _apiService.createEvent(eventData.toJson());
      return Event.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to create event: $e');
    }
  }

  // Update event (organizer/admin only)
  Future<Event> updateEvent(int id, EventUpdate eventData) async {
    try {
      final response = await _apiService.updateEvent(id, eventData.toJson());
      return Event.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update event: $e');
    }
  }

  // Delete event (organizer/admin only)
  Future<void> deleteEvent(int id) async {
    try {
      await _apiService.deleteEvent(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to delete event: $e');
    }
  }
}
