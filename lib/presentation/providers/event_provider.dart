import 'package:flutter/material.dart';
import '../../core/services/event_service.dart';
import '../../core/services/database_service.dart';
import '../../data/models/event.dart';
import '../../data/models/common.dart';
// ignore: unused_import
import '../../data/models/user_model.dart';

enum EventLoadingState {
  initial,
  loading,
  loaded,
  error,
  refreshing,
}

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();
  final DatabaseService _dbService = DatabaseService.instance;
  
  // State
  EventLoadingState _loadingState = EventLoadingState.initial;
  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  String? _errorMessage;
  
  // Filters and search
  EventStatusFilter _statusFilter = EventStatusFilter.all;
  EventCategory? _categoryFilter;
  String _searchQuery = '';
  String? _departmentFilter;
  
  // Pagination
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreEvents = true;
  
  // Getters
  EventLoadingState get loadingState => _loadingState;
  List<Event> get events => _filteredEvents;
  String? get errorMessage => _errorMessage;
  EventStatusFilter get statusFilter => _statusFilter;
  EventCategory? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;
  String? get departmentFilter => _departmentFilter;
  bool get hasMoreEvents => _hasMoreEvents;
  bool get isLoading => _loadingState == EventLoadingState.loading;
  bool get isRefreshing => _loadingState == EventLoadingState.refreshing;
  bool get hasError => _loadingState == EventLoadingState.error;
  
  // Initialize and load events
  Future<void> loadEvents({bool refresh = false}) async {
    if (refresh) {
      _loadingState = EventLoadingState.refreshing;
      _currentPage = 0;
      _hasMoreEvents = true;
    } else if (_loadingState == EventLoadingState.loading) {
      return; // Already loading
    } else {
      _loadingState = EventLoadingState.loading;
    }
    
    _errorMessage = null;
    notifyListeners();
    
    try {
      final events = await _fetchEventsFromAPI();
      
      if (refresh) {
        _events = events;
      } else {
        _events.addAll(events);
      }
      
      _applyFilters();
      _loadingState = EventLoadingState.loaded;
      _hasMoreEvents = events.length == _pageSize;
      
    } catch (e) {
      _loadingState = EventLoadingState.error;
      _errorMessage = e.toString();
      print('Error loading events: $e');
    }
    
    notifyListeners();
  }
  
  Future<List<Event>> _fetchEventsFromAPI() async {
    try {
      print('EventProvider: Fetching events from API...');
      final page = _currentPage + 1; // API uses 1-based pagination
      
      // Convert filters to API parameters
      EventStatus? status;
      if (_statusFilter != EventStatusFilter.all) {
        switch (_statusFilter) {
          case EventStatusFilter.draft:
            status = EventStatus.draft;
            break;
          case EventStatusFilter.published:
            status = EventStatus.published;
            break;
          case EventStatusFilter.cancelled:
            status = EventStatus.cancelled;
            break;
          case EventStatusFilter.completed:
            status = EventStatus.completed;
            break;
          case EventStatusFilter.upcoming:
            status = EventStatus.published; // Upcoming events are published
            break;
          case EventStatusFilter.ongoing:
            status = EventStatus.ongoing;
            break;
          case EventStatusFilter.all:
            break;
        }
      }
      
      print('EventProvider: Fetching events with page: $page, category: ${_categoryFilter?.toJson()}, status: ${status?.toJson()}, search: $_searchQuery');
      
      final response = await _eventService.getEvents(
        page: page,
        size: _pageSize,
        category: _categoryFilter,
        status: status,
      );
      
      print('EventProvider: API returned ${response.items.length} events');
      print('EventProvider: Total events: ${response.total}');
      
      _currentPage++;
      
      // Apply local filters that can't be done on the API
      List<Event> filteredEvents = response.items;
      
      // Filter out cancelled events (unless specifically requested)
      if (_statusFilter != EventStatusFilter.cancelled) {
        filteredEvents = filteredEvents.where((event) => event.status != EventStatus.cancelled).toList();
      }
      
      // Apply search filter locally if needed
      if (_searchQuery.isNotEmpty) {
        filteredEvents = filteredEvents.where((event) {
          return event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 event.description.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
      
      // Apply department filter locally if needed
      if (_departmentFilter != null && _departmentFilter!.isNotEmpty) {
        filteredEvents = filteredEvents.where((event) {
          return event.department.toLowerCase().contains(_departmentFilter!.toLowerCase());
        }).toList();
      }
      
      print('EventProvider: After local filtering: ${filteredEvents.length} events');
      return filteredEvents;
      
    } catch (e) {
      print('API fetch failed, returning mock data: $e');
      // Return mock data if API fails
      return _getMockEvents();
    }
  }

  List<Event> _getMockEvents() {
    // Return some mock events when database is not available
    return [
      Event.create(
        id: 1,
        title: 'Tech Symposium 2024',
        description: 'A grand technology symposium featuring industry experts and innovative ideas.',
        category: EventCategory.technical,
        status: EventStatus.published,
        organizerId: 1,
        startDate: DateTime.now().add(const Duration(days: 5)).copyWith(hour: 10, minute: 0),
        endDate: DateTime.now().add(const Duration(days: 5)).copyWith(hour: 18, minute: 0),
        venue: 'Main Auditorium',
        maxParticipants: 200,
        department: 'Computer Science',
        tags: ['technology', 'innovation', 'networking'],
      ),
      Event.create(
        id: 2,
        title: 'Cultural Festival',
        description: 'Annual cultural festival showcasing diverse talents and traditions.',
        category: EventCategory.cultural,
        status: EventStatus.published,
        organizerId: 2,
        startDate: DateTime.now().add(const Duration(days: 10)).copyWith(hour: 14, minute: 0),
        endDate: DateTime.now().add(const Duration(days: 10)).copyWith(hour: 22, minute: 0),
        venue: 'Cultural Center',
        maxParticipants: 500,
        department: 'Arts & Humanities',
        tags: ['culture', 'performance', 'festival'],
      ),
    ];
  }
  
  void _applyFilters() {
    print('EventProvider: Applying filters - _events.length: ${_events.length}');
    _filteredEvents = List.from(_events);
    print('EventProvider: After applying filters - _filteredEvents.length: ${_filteredEvents.length}');
    
    // Apply local filters if needed (in addition to database filters)
    // This can be used for real-time filtering without database queries
  }
  
  // Filter methods
  void setStatusFilter(EventStatusFilter filter) {
    if (_statusFilter != filter) {
      _statusFilter = filter;
      _refreshEvents();
    }
  }
  
  void setCategoryFilter(EventCategory? category) {
    if (_categoryFilter != category) {
      _categoryFilter = category;
      _refreshEvents();
    }
  }
  
  void setDepartmentFilter(String? department) {
    if (_departmentFilter != department) {
      _departmentFilter = department;
      _refreshEvents();
    }
  }
  
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _refreshEvents();
    }
  }
  
  void clearFilters() {
    _statusFilter = EventStatusFilter.all;
    _categoryFilter = null;
    _departmentFilter = null;
    _searchQuery = '';
    _refreshEvents();
  }
  
  void _refreshEvents() {
    _events.clear();
    _filteredEvents.clear();
    _currentPage = 0;
    _hasMoreEvents = true;
    loadEvents();
  }
  
  // Event CRUD operations
  Future<bool> createEvent(Event event) async {
    try {
      print('EventProvider: Creating event with data: ${event.toMap()}');
      
      // Convert Event to EventCreate for API
      print('EventProvider: Event.isPaidEvent = ${event.isPaidEvent}');
      print('EventProvider: Event.currency = ${event.currency}');
      
      final eventCreate = EventCreate(
        title: event.title,
        description: event.description,
        category: event.category,
        startDate: event.startDate,
        endDate: event.endDate,
        venue: event.venue,
        maxParticipants: event.maxParticipants,
        registrationFee: event.registrationFee,
        isPaidEvent: event.isPaidEvent,
        currency: event.currency,
        requirements: event.requirements,
        eventAgenda: event.eventAgenda,
        isFeatured: event.isFeatured,
      );
      
      print('EventProvider: EventCreate.toJson() = ${eventCreate.toJson()}');
      
      final createdEvent = await _eventService.createEvent(eventCreate);
      print('EventProvider: Event created successfully via API: ${createdEvent.title}');
      
      // Refresh events from API to get the latest data
      await loadEvents(refresh: true);
      
      return true;
    } catch (e) {
      print('Error creating event: $e');
      _errorMessage = 'Failed to create event: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateEvent(Event event) async {
    try {
      await _dbService.update(
        'events',
        event.toMap(),
        where: 'event_id = ?',
        whereArgs: [event.eventId],
      );
      
      // Update local list
      final index = _events.indexWhere((e) => e.eventId == event.eventId);
      if (index != -1) {
        _events[index] = event;
        _applyFilters();
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update event: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _dbService.delete(
        'events',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      
      // Remove from local list
      _events.removeWhere((event) => event.eventId == eventId);
      _applyFilters();
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete event: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<Event?> getEventById(String eventId) async {
    try {
      // First check local cache
      final localEvent = _events.firstWhere(
        (event) => event.eventId == eventId,
        orElse: () => throw StateError('Event not found locally'),
      );
      
      return localEvent;
        } catch (e) {
      // Event not in local cache, fetch from database
    }
    
    try {
      final data = await _dbService.query(
        'events',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      
      if (data.isNotEmpty) {
        return Event.fromMap(data.first);
      }
      
      return null;
    } catch (e) {
      _errorMessage = 'Failed to get event: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Get events by organizer
  Future<List<Event>> getEventsByOrganizer(String organizerId) async {
    try {
      final data = await _dbService.query(
        'events',
        where: 'organizer_id = ?',
        whereArgs: [organizerId],
        orderBy: 'created_at DESC',
      );
      
      return data.map((map) => Event.fromMap(map)).toList();
    } catch (e) {
      _errorMessage = 'Failed to get organizer events: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Get upcoming events
  Future<List<Event>> getUpcomingEvents({int limit = 10}) async {
    try {
      final data = await _dbService.query(
        'events',
        where: 'event_date > ? AND status = ?',
        whereArgs: [DateTime.now().toIso8601String(), 'published'],
        orderBy: 'event_date ASC',
        limit: limit,
      );
      
      return data.map((map) => Event.fromMap(map)).toList();
    } catch (e) {
      _errorMessage = 'Failed to get upcoming events: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Get events by category
  Future<List<Event>> getEventsByCategory(EventCategory category, {int limit = 10}) async {
    try {
      final data = await _dbService.query(
        'events',
        where: 'category = ? AND status = ?',
        whereArgs: [category.toJson(), 'published'],
        orderBy: 'event_date ASC',
        limit: limit,
      );
      
      return data.map((map) => Event.fromMap(map)).toList();
    } catch (e) {
      _errorMessage = 'Failed to get events by category: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Event registration methods
  Future<bool> registerForEvent(String eventId, String studentId) async {
    try {
      final registrationData = {
        'registration_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'event_id': eventId,
        'student_id': studentId,
        'registration_status': 'pending',
        'payment_status': 'pending',
        'registered_at': DateTime.now().toIso8601String(),
      };
      
      await _dbService.insert('event_registrations', registrationData);
      
      // Update participant count
      await _incrementParticipantCount(eventId);
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to register for event: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> unregisterFromEvent(String eventId, String studentId) async {
    try {
      await _dbService.delete(
        'event_registrations',
        where: 'event_id = ? AND student_id = ?',
        whereArgs: [eventId, studentId],
      );
      
      // Update participant count
      await _decrementParticipantCount(eventId);
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to unregister from event: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> isRegisteredForEvent(String eventId, String studentId) async {
    try {
      final data = await _dbService.query(
        'event_registrations',
        where: 'event_id = ? AND student_id = ?',
        whereArgs: [eventId, studentId],
      );
      
      return data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> _incrementParticipantCount(String eventId) async {
    try {
      await _dbService.rawUpdate(
        'UPDATE events SET current_participants = current_participants + 1 WHERE event_id = ?',
        [eventId],
      );
      
      // Update local cache
      final index = _events.indexWhere((e) => e.eventId == eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(
          currentParticipants: _events[index].currentParticipants + 1,
        );
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      print('Error incrementing participant count: $e');
    }
  }
  
  Future<void> _decrementParticipantCount(String eventId) async {
    try {
      await _dbService.rawUpdate(
        'UPDATE events SET current_participants = current_participants - 1 WHERE event_id = ?',
        [eventId],
      );
      
      // Update local cache
      final index = _events.indexWhere((e) => e.eventId == eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(
          currentParticipants: _events[index].currentParticipants - 1,
        );
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      print('Error decrementing participant count: $e');
    }
  }
  
  // Utility methods
  
  // Get unique departments for filter
  Future<List<String>> getDepartments() async {
    try {
      final data = await _dbService.rawQuery(
        'SELECT DISTINCT department FROM events WHERE department IS NOT NULL ORDER BY department',
      );
      
      return data.map((row) => row['department'].toString()).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Load more events (pagination)
  Future<void> loadMoreEvents() async {
    if (_hasMoreEvents && _loadingState != EventLoadingState.loading) {
      await loadEvents();
    }
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}