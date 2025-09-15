import 'api_service.dart';
import '../constants/api_constants.dart';
import '../../data/models/registration.dart';
import '../../data/models/common.dart';

class RegistrationService {
  static final RegistrationService _instance = RegistrationService._internal();
  factory RegistrationService() => _instance;
  RegistrationService._internal();

  final ApiService _apiService = ApiService.instance;

  // Get all registrations for an event
  Future<PaginatedResponse<Registration>> getEventRegistrations(int eventId, {int page = 1, int size = 10}) async {
    try {
      // Since ApiService doesn't have getEventRegistrations, we'll get all registrations and filter
      final response = await _apiService.getMyRegistrations();
      
      // Convert to list of registration items and filter by eventId
      final allRegistrations = response.map((json) => Registration.fromJson(json as Map<String, dynamic>)).toList();
      final eventRegistrations = allRegistrations.where((registration) => registration.eventId == eventId).toList();
      
      // Apply pagination
      final startIndex = (page - 1) * size;
      final endIndex = startIndex + size;
      final paginatedItems = eventRegistrations.length > startIndex 
          ? eventRegistrations.sublist(startIndex, endIndex.clamp(0, eventRegistrations.length))
          : <Registration>[];
      
      return PaginatedResponse<Registration>(
        items: paginatedItems,
        total: eventRegistrations.length,
        page: page,
        size: size,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch event registrations: $e');
    }
  }

  // Register for an event
  Future<Registration> registerForEvent(RegistrationCreate registrationData) async {
    try {
      final response = await _apiService.registerForEvent(registrationData.eventId);
      return Registration.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to register for event: $e');
    }
  }

  // Update registration status (organizer/admin only)
  Future<Registration> updateRegistrationStatus(int id, RegistrationUpdate registrationData) async {
    try {
      // Since ApiService doesn't have updateRegistration, we'll need to implement this
      // For now, we'll throw an exception indicating this feature needs backend support
      throw ApiException('Update registration feature requires backend support. Please contact administrator.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update registration: $e');
    }
  }

  // Cancel registration
  Future<void> cancelRegistration(int id) async {
    try {
      await _apiService.cancelRegistration(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to cancel registration: $e');
    }
  }

  // Get my registrations
  Future<PaginatedResponse<Registration>> getMyRegistrations({int page = 1, int size = 10}) async {
    try {
      final response = await _apiService.getMyRegistrations();
      
      // Convert response to list of Registration objects
      final items = response.map((json) => Registration.fromJson(json as Map<String, dynamic>)).toList();
      
      // Apply pagination
      final startIndex = (page - 1) * size;
      final endIndex = startIndex + size;
      final paginatedItems = items.length > startIndex 
          ? items.sublist(startIndex, endIndex.clamp(0, items.length))
          : <Registration>[];
      
      return PaginatedResponse<Registration>(
        items: paginatedItems,
        total: items.length,
        page: page,
        size: size,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch my registrations: $e');
    }
  }

  // Check if user is registered for an event
  Future<bool> isUserRegisteredForEvent(int eventId) async {
    try {
      // Since ApiService doesn't have isUserRegisteredForEvent, we'll get all registrations and check
      final response = await _apiService.getMyRegistrations();
      
      // Convert to list of registration items and check if any match the eventId
      final allRegistrations = response.map((json) => Registration.fromJson(json as Map<String, dynamic>)).toList();
      return allRegistrations.any((registration) => registration.eventId == eventId);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to check registration status: $e');
    }
  }

  // Get registration by ID
  Future<Registration> getRegistrationById(int id) async {
    try {
      // Since ApiService doesn't have getRegistrationById, we'll get all registrations and find by ID
      final response = await _apiService.getMyRegistrations();
      
      // Convert to list of registration items and find by ID
      final allRegistrations = response.map((json) => Registration.fromJson(json as Map<String, dynamic>)).toList();
      final registration = allRegistrations.firstWhere(
        (reg) => reg.id == id,
        orElse: () => throw ApiException('Registration with ID $id not found'),
      );
      
      return registration;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch registration: $e');
    }
  }
}
