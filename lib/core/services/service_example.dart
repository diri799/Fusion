// Example usage of the API services
// This file demonstrates how to use the services in your Flutter app

import 'auth_service.dart';
import 'event_service.dart';
import 'user_service.dart';

class ServiceExample {
  final AuthService _authService = AuthService();
  final EventService _eventService = EventService();
  final UserService _userService = UserService();

  Future<void> runExamples() async {
    // 1. Authentication Example
    await _authExample();

    // 2. Event Service Example
    await _eventExample();

    // 3. User Service Example
    await _userExample();
  }

  Future<void> _authExample() async {
    try {
      // Login example
      final loginResult = await _authService.login(
        email: 'admin@example.com',
        password: 'adminpassword',
      );
      print('Login successful: ${loginResult.isSuccess}');

      final isLoggedIn = _authService.isLoggedIn;
      print('Is logged in: $isLoggedIn');

      // Get current user profile
      await _userService.getCurrentUserProfile();
      // print('User profile retrieved');

      // Logout
      await _authService.logout();
      print('Logout successful.');
      final isLoggedOut = _authService.isLoggedIn;
      print('Is logged in after logout: $isLoggedOut');
    } catch (e) {
      // print('Auth Error: $e');
    }
  }

  Future<void> _eventExample() async {
    try {
      // Fetch all events
      final events = await _eventService.getEvents();
      // print('Fetched ${events.items.length} events. Total: ${events.total}');

      if (events.items.isNotEmpty) {
        final event = events.items.first;
        // print('First event: ${event.title}');

        // Fetch event by ID
        await _eventService.getEventById(event.id);
        // print('Fetched event by ID: ${fetchedEvent.title}');
      }

      // Example of creating an event (requires organizer/admin role)
      // await _authService.login('organizer@example.com', 'organizerpassword');
      // final newEvent = await _eventService.createEvent(
      //   EventCreate(
      //     title: 'New Test Event',
      //     description: 'This is a test event created from Flutter.',
      //     startTime: DateTime.now().add(Duration(days: 7)),
      //     endTime: DateTime.now().add(Duration(days: 7, hours: 2)),
      //     location: 'Virtual',
      //     category: EventCategory.workshop,
      //   ),
      // );
      // print('Created new event: ${newEvent.title}');
      // await _authService.logout();
    } catch (e) {
      // print('Event Service Error: $e');
    }
  }

  Future<void> _userExample() async {
    try {
      // Get current user profile
      // final user = await _userService.getCurrentUserProfile();
      // print('Current user: ${user.username}, Role: ${user.role}');

      // Example of updating user profile (requires login)
      // await _authService.login('student@example.com', 'studentpassword');
      // final updatedUser = await _userService.updateUserProfile(
      //   UserUpdate(username: 'new_student_name'),
      // );
      // print('Updated user profile: ${updatedUser.username}');
      // await _authService.logout();

      // Example of getting all users (requires admin login)
      // await _authService.login('admin@example.com', 'adminpassword');
      // final users = await _userService.getUsers();
      // print('Total users (admin view): ${users.total}');
      // await _authService.logout();
    } catch (e) {
      // print('User Service Error: $e');
    }
  }
}
