import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://fuse-back.onrender.com/api';
  static const String authUrl = '$baseUrl/auth';
  static const String usersUrl = '$baseUrl/users';
  static const String eventsUrl = '$baseUrl/events';
  static const String registrationsUrl = '$baseUrl/registrations';
  static const String feedbackUrl = '$baseUrl/feedback';
  static const String mediaUrl = '$baseUrl/media';

  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  ApiService._();

  String? _accessToken;

  Future<String?> get accessToken async {
    if (_accessToken != null) return _accessToken;

    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    return _accessToken;
  }

  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<void> clearToken() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> get _authHeaders async {
    final token = await accessToken;
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Token expired or invalid
      await clearToken();
      throw Exception('Authentication failed. Please login again.');
    }
    return response;
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('Login attempt with email: $email');
    print('Login URL: $authUrl/login');
    
    // Extract username from email (everything before @)
    final username = email.split('@')[0];
    print('Extracted username: $username');
    
    try {
      // Try form data with username first (most likely to work)
      final formData = {
        'username': username,
        'password': password,
      };
      
      print('Login form data with username: $formData');
      
      final response = await http.post(
        Uri.parse('$authUrl/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: formData.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&'),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response headers: ${response.headers}');
      print('Login response body: ${response.body}');

      final handledResponse = await _handleResponse(response);

      if (handledResponse.statusCode == 200) {
        final data = jsonDecode(handledResponse.body);
        await setAccessToken(data['access_token']);
        return data;
      } else {
        // If username login fails, try with email
        print('Username login failed, trying with email...');
        return await _loginWithJson(email, password);
      }
    } catch (e) {
      print('Login exception: $e');
      // Try multiple login approaches as fallback
      try {
        return await _loginWithJson(email, password);
      } catch (jsonError) {
        print('All login attempts failed: $jsonError');
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> _loginWithJson(String email, String password) async {
    // Try different login approaches based on backend requirements
    final loginAttempts = [
      // Attempt 1: Form data with username field
      () => _tryFormDataLogin(email, password, 'username'),
      // Attempt 2: Form data with email field  
      () => _tryFormDataLogin(email, password, 'email'),
      // Attempt 3: JSON with username field
      () => _tryJsonLogin(email, password, 'username'),
      // Attempt 4: JSON with email field
      () => _tryJsonLogin(email, password, 'email'),
    ];

    Exception? lastException;
    
    for (final attempt in loginAttempts) {
      try {
        final result = await attempt();
        return result;
      } catch (e) {
        print('Login attempt failed: $e');
        lastException = e as Exception;
        continue;
      }
    }
    
    throw lastException ?? Exception('All login attempts failed');
  }

  Future<Map<String, dynamic>> _tryFormDataLogin(String email, String password, String fieldName) async {
    final formData = {
      fieldName: email,
      'password': password,
    };
    
    print('Trying form data login with $fieldName: $formData');
    
    final response = await http.post(
      Uri.parse('$authUrl/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: formData.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&'),
    );

    print('Form data login response status: ${response.statusCode}');
    print('Form data login response body: ${response.body}');

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200) {
      final data = jsonDecode(handledResponse.body);
      await setAccessToken(data['access_token']);
      return data;
    } else {
      throw Exception('Form data login failed: ${handledResponse.body}');
    }
  }

  Future<Map<String, dynamic>> _tryJsonLogin(String email, String password, String fieldName) async {
    final requestBody = {
      fieldName: email,
      'password': password,
    };
    
    print('Trying JSON login with $fieldName: $requestBody');
    
    final response = await http.post(
      Uri.parse('$authUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('JSON login response status: ${response.statusCode}');
    print('JSON login response body: ${response.body}');

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200) {
      final data = jsonDecode(handledResponse.body);
      await setAccessToken(data['access_token']);
      return data;
    } else {
      throw Exception('JSON login failed: ${handledResponse.body}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    // Validate required fields
    if (email.isEmpty) {
      throw Exception('Email is required');
    }
    if (username.isEmpty) {
      throw Exception('Username is required');
    }
    if (password.isEmpty) {
      throw Exception('Password is required');
    }
    if (role.isEmpty) {
      throw Exception('Role is required');
    }

    // Map frontend role values to backend expected values
    String mappedRole = _mapRoleToBackend(role);
    
    final requestBody = {
      'email': email.trim(),
      'username': username.trim(),
      'password': password,
      'role': mappedRole,
    };
    
    print('Registration request body: $requestBody');
    print('Registration request body JSON: ${jsonEncode(requestBody)}');
    print('Registration URL: $authUrl/register');
    print('Original role: $role, Mapped role: $mappedRole');
    
    // Validate that all required fields are present and non-empty
    final missingFields = <String>[];
    if (requestBody['email']?.toString().isEmpty == true) missingFields.add('email');
    if (requestBody['username']?.toString().isEmpty == true) missingFields.add('username');
    if (requestBody['password']?.toString().isEmpty == true) missingFields.add('password');
    if (requestBody['role']?.toString().isEmpty == true) missingFields.add('role');
    
    if (missingFields.isNotEmpty) {
      throw Exception('Missing required fields: ${missingFields.join(', ')}');
    }
    
    try {
      final response = await http.post(
        Uri.parse('$authUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Registration response status: ${response.statusCode}');
      print('Registration response headers: ${response.headers}');
      print('Registration response body: ${response.body}');

      final handledResponse = await _handleResponse(response);

      if (handledResponse.statusCode == 200 ||
          handledResponse.statusCode == 201) {
        return jsonDecode(handledResponse.body);
      } else {
        throw Exception('Registration failed: ${handledResponse.body}');
      }
    } catch (e) {
      print('Registration exception: $e');
      rethrow;
    }
  }

  // Map frontend role values to backend expected values
  String _mapRoleToBackend(String frontendRole) {
    switch (frontendRole) {
      case 'student_visitor':
      case 'student_participant':
        return 'student';
      case 'organizer':
        return 'organizer';
      case 'admin':
        return 'admin';
      default:
        print('Unknown role: $frontendRole, defaulting to student');
        return 'student';
    }
  }

  // User endpoints
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$usersUrl/me'),
      headers: await _authHeaders,
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to get user data: ${handledResponse.body}');
    }
  }

  Future<Map<String, dynamic>> updateUserDetails(
    Map<String, dynamic> userDetails,
  ) async {
    final response = await http.put(
      Uri.parse('$usersUrl/me/details'),
      headers: await _authHeaders,
      body: jsonEncode(userDetails),
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to update user details: ${handledResponse.body}');
    }
  }

  // Event endpoints
  Future<Map<String, dynamic>> getEvents({
    int page = 1,
    int size = 20,
    String? category,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };

    if (category != null) queryParams['category'] = category;
    if (status != null) queryParams['status'] = status;

    final uri = Uri.parse('$eventsUrl/').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _authHeaders);

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to get events: ${handledResponse.body}');
    }
  }

  Future<Map<String, dynamic>> getEvent(int eventId) async {
    final response = await http.get(
      Uri.parse('$eventsUrl/$eventId'),
      headers: await _authHeaders,
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to get event: ${handledResponse.body}');
    }
  }

  Future<Map<String, dynamic>> createEvent(
    Map<String, dynamic> eventData,
  ) async {
    final response = await http.post(
      Uri.parse('$eventsUrl/'),
      headers: await _authHeaders,
      body: jsonEncode(eventData),
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200 ||
        handledResponse.statusCode == 201) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to create event: ${handledResponse.body}');
    }
  }

  Future<Map<String, dynamic>> updateEvent(
    int eventId,
    Map<String, dynamic> eventData,
  ) async {
    final response = await http.put(
      Uri.parse('$eventsUrl/$eventId'),
      headers: await _authHeaders,
      body: jsonEncode(eventData),
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to update event: ${handledResponse.body}');
    }
  }

  Future<void> deleteEvent(int eventId) async {
    final response = await http.delete(
      Uri.parse('$eventsUrl/$eventId'),
      headers: await _authHeaders,
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode != 200 &&
        handledResponse.statusCode != 204) {
      throw Exception('Failed to delete event: ${handledResponse.body}');
    }
  }

  // Registration endpoints
  Future<Map<String, dynamic>> registerForEvent(int eventId) async {
    final response = await http.post(
      Uri.parse('$registrationsUrl/'),
      headers: await _authHeaders,
      body: jsonEncode({'event_id': eventId}),
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200 ||
        handledResponse.statusCode == 201) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to register for event: ${handledResponse.body}');
    }
  }

  Future<List<dynamic>> getMyRegistrations() async {
    final response = await http.get(
      Uri.parse('$registrationsUrl/my-registrations'),
      headers: await _authHeaders,
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to get registrations: ${handledResponse.body}');
    }
  }

  Future<void> cancelRegistration(int registrationId) async {
    final response = await http.delete(
      Uri.parse('$registrationsUrl/$registrationId'),
      headers: await _authHeaders,
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode != 200 &&
        handledResponse.statusCode != 204) {
      throw Exception('Failed to cancel registration: ${handledResponse.body}');
    }
  }

  // Feedback endpoints
  Future<Map<String, dynamic>> submitFeedback({
    required int eventId,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$feedbackUrl/'),
      headers: await _authHeaders,
      body: jsonEncode({
        'event_id': eventId,
        'rating': rating,
        'comment': comment,
      }),
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200 ||
        handledResponse.statusCode == 201) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to submit feedback: ${handledResponse.body}');
    }
  }

  Future<List<dynamic>> getMyFeedback() async {
    final response = await http.get(
      Uri.parse('$feedbackUrl/my-feedback'),
      headers: await _authHeaders,
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to get feedback: ${handledResponse.body}');
    }
  }

  // Media endpoints
  Future<List<dynamic>> getMediaGallery() async {
    final response = await http.get(
      Uri.parse('$mediaUrl/'),
      headers: await _authHeaders,
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to get media gallery: ${handledResponse.body}');
    }
  }

  Future<Map<String, dynamic>> uploadMedia({
    required String title,
    required String description,
    required String fileUrl,
    required String mediaType,
  }) async {
    final response = await http.post(
      Uri.parse('$mediaUrl/'),
      headers: await _authHeaders,
      body: jsonEncode({
        'title': title,
        'description': description,
        'file_url': fileUrl,
        'media_type': mediaType,
      }),
    );

    final handledResponse = await _handleResponse(response);

    if (handledResponse.statusCode == 200 ||
        handledResponse.statusCode == 201) {
      return jsonDecode(handledResponse.body);
    } else {
      throw Exception('Failed to upload media: ${handledResponse.body}');
    }
  }

  // Generic HTTP methods for other services
  Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders,
    );
    return await _handleResponse(response);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return await _handleResponse(response);
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return await _handleResponse(response);
  }

  Future<http.Response> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders,
    );
    return await _handleResponse(response);
  }
}
