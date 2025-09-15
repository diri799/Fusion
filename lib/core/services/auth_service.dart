import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'database_service.dart';
import '../../data/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static AuthService get instance => _instance;

  final DatabaseService _dbService = DatabaseService.instance;
  final ApiService _apiService = ApiService.instance;
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();

  User? _currentUser;
  String? _currentToken;
  
  // Web-compatible storage
  Map<String, String> _webStorage = {};

  // Getters
  User? get currentUser => _currentUser;
  String? get currentToken => _currentToken;
  bool get isLoggedIn => _currentUser != null;
  Stream<User?> get userStream => _userController.stream;

  // Initialize auth service
  Future<void> initialize() async {
    await _loadUserFromStorage();
  }

  // Load user from persistent storage
  Future<void> _loadUserFromStorage() async {
    try {
      String? userId;
      String? token;
      
      if (kIsWeb) {
        // For web, load from in-memory storage
        userId = _webStorage['current_user_id'];
        token = _webStorage['auth_token'];
        print('Web: Loading user from storage - $userId');
      } else {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('current_user_id');
        token = prefs.getString('auth_token');
        print('Mobile: Loading user from SharedPreferences');
      }

      if (userId != null && token != null) {
        final userData = await _dbService.query(
          'users',
          where: 'user_id = ?',
          whereArgs: [userId],
        );

        if (userData.isNotEmpty) {
          final user = User.fromMap(userData.first);

          // Load user details
          final detailsData = await _dbService.query(
            'user_details',
            where: 'user_id = ?',
            whereArgs: [userId],
          );

          User userWithDetails = user;
          if (detailsData.isNotEmpty) {
            final details = UserDetails.fromMap(detailsData.first);
            userWithDetails = user.copyWith(details: details);
          }

          _currentUser = userWithDetails;
          _currentToken = token;
          _userController.add(_currentUser);
        }
      }
    } catch (e) {
      print('Error loading user from storage: $e');
      // Fallback to web storage if SharedPreferences fails
      if (!kIsWeb) {
        try {
          final userId = _webStorage['current_user_id'];
          final token = _webStorage['auth_token'];
          if (userId != null && token != null) {
            print('Fallback: Loading user from web storage - $userId');
            // For fallback, we'll just set the token without loading full user data
            _currentToken = token;
          }
        } catch (fallbackError) {
          print('Fallback loading also failed: $fallbackError');
        }
      }
    }
  }

  // Save user to persistent storage
  Future<void> _saveUserToStorage(User user, String token) async {
    try {
      if (kIsWeb) {
        // For web, use simple in-memory storage
        _webStorage['current_user_id'] = user.userId;
        _webStorage['auth_token'] = token;
        print('Web: Saved user to storage - ${user.userId}');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', user.userId);
      await prefs.setString('auth_token', token);
      print('Mobile: Saved user to SharedPreferences');
    } catch (e) {
      print('Error saving user to storage: $e');
      // Fallback to web storage if SharedPreferences fails
      _webStorage['current_user_id'] = user.userId;
      _webStorage['auth_token'] = token;
      print('Fallback: Saved user to web storage');
    }
  }

  // Clear user from persistent storage
  Future<void> _clearUserFromStorage() async {
    try {
      if (kIsWeb) {
        // For web, clear in-memory storage
        _webStorage.remove('current_user_id');
        _webStorage.remove('auth_token');
        print('Web: Cleared user from storage');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      await prefs.remove('auth_token');
      print('Mobile: Cleared user from SharedPreferences');
    } catch (e) {
      print('Error clearing user from storage: $e');
      // Fallback to web storage clearing
      _webStorage.remove('current_user_id');
      _webStorage.remove('auth_token');
      print('Fallback: Cleared user from web storage');
    }
  }

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate authentication token (kept for potential future use)
  // String _generateToken() {
  //   final random = Random.secure();
  //   final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  //   return base64Url.encode(bytes);
  // }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  Map<String, dynamic> _validatePassword(String password) {
    final errors = <String>[];

    if (password.length < 8) {
      errors.add('Password must be at least 8 characters long');
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('Password must contain at least one uppercase letter');
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('Password must contain at least one lowercase letter');
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('Password must contain at least one number');
    }

    return {'isValid': errors.isEmpty, 'errors': errors};
  }

  // Register new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String confirmPassword,
    required UserRole role,
    required String fullName,
    String? mobileNumber,
    String? department,
    String? enrollmentNo,
    String? collegeId,
  }) async {
    try {
      // Validate input
      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      if (password != confirmPassword) {
        return AuthResult.failure('Passwords do not match');
      }

      final passwordValidation = _validatePassword(password);
      if (!passwordValidation['isValid']) {
        return AuthResult.failure(passwordValidation['errors'].join(', '));
      }

      if (fullName.trim().isEmpty) {
        return AuthResult.failure('Full name is required');
      }

      // Call backend API for registration
      await _apiService.register(
        email: email.toLowerCase(),
        username: email.split('@')[0], // Use email prefix as username
        password: password,
        role: role.value,
      );

      // After successful registration, login the user
      final loginResponse = await _apiService.login(email, password);
      final token = loginResponse['access_token'];

      // Get user details from API
      final userData = await _apiService.getCurrentUser();

      // Convert API response to User model
      final user = User.fromApiResponse(userData);
      _currentUser = user;
      _currentToken = token;

      await _saveUserToStorage(user, token);
      _userController.add(_currentUser);

      return AuthResult.success(user: user, token: token);
    } catch (e) {
      print('Registration error: $e');
      return AuthResult.failure('Registration failed. Please try again.');
    }
  }

  // Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      if (password.isEmpty) {
        return AuthResult.failure('Password is required');
      }

      // Call backend API
      final response = await _apiService.login(email, password);
      final token = response['access_token'];

      // Get user details from API
      final userData = await _apiService.getCurrentUser();

      // Convert API response to User model
      final user = User.fromApiResponse(userData);
      _currentUser = user;
      _currentToken = token;

      await _saveUserToStorage(user, token);
      _userController.add(_currentUser);

      return AuthResult.success(user: user, token: token);
    } catch (e) {
      print('Login error: $e');
      return AuthResult.failure('Login failed. Please check your credentials.');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      print('Starting logout process...');
      await _clearUserFromStorage();
      _currentUser = null;
      _currentToken = null;
      _userController.add(null);
      print('Logout completed successfully');
    } catch (e) {
      print('Logout error: $e');
      // Even if clearing storage fails, ensure user is logged out
      _currentUser = null;
      _currentToken = null;
      _userController.add(null);
      print('Logout completed with fallback (cleared in-memory state)');
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      if (_currentUser == null) {
        return AuthResult.failure('User not logged in');
      }

      // Validate current password
      if (_currentUser!.password != _hashPassword(currentPassword)) {
        return AuthResult.failure('Current password is incorrect');
      }

      // Validate new password
      if (newPassword != confirmNewPassword) {
        return AuthResult.failure('New passwords do not match');
      }

      final passwordValidation = _validatePassword(newPassword);
      if (!passwordValidation['isValid']) {
        return AuthResult.failure(passwordValidation['errors'].join(', '));
      }

      // Update password in database
      await _dbService.update(
        'users',
        {
          'password': _hashPassword(newPassword),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ?',
        whereArgs: [_currentUser!.userId],
      );

      // Update current user
      _currentUser = _currentUser!.copyWith(
        password: _hashPassword(newPassword),
        updatedAt: DateTime.now(),
      );

      _userController.add(_currentUser);

      return AuthResult.success(user: _currentUser!, token: _currentToken!);
    } catch (e) {
      print('Change password error: $e');
      return AuthResult.failure('Failed to change password. Please try again.');
    }
  }

  // Update user profile
  Future<AuthResult> updateProfile({
    String? fullName,
    String? mobileNumber,
    String? department,
    String? enrollmentNo,
    String? collegeId,
    String? bio,
    int? yearOfStudy,
    String? course,
  }) async {
    try {
      if (_currentUser == null) {
        return AuthResult.failure('User not logged in');
      }

      final currentDetails = _currentUser!.details;
      if (currentDetails == null) {
        return AuthResult.failure('User details not found');
      }

      // Update user details
      final updatedDetails = currentDetails.copyWith(
        fullName: fullName ?? currentDetails.fullName,
        mobileNumber: mobileNumber ?? currentDetails.mobileNumber,
        department: department ?? currentDetails.department,
        enrollmentNo: enrollmentNo ?? currentDetails.enrollmentNo,
        collegeId: collegeId ?? currentDetails.collegeId,
        bio: bio ?? currentDetails.bio,
        yearOfStudy: yearOfStudy ?? currentDetails.yearOfStudy,
        course: course ?? currentDetails.course,
        updatedAt: DateTime.now(),
      );

      // Save to database
      await _dbService.update(
        'user_details',
        updatedDetails.toMap(),
        where: 'user_id = ?',
        whereArgs: [_currentUser!.userId],
      );

      // Update current user
      _currentUser = _currentUser!.copyWith(details: updatedDetails);
      _userController.add(_currentUser);

      return AuthResult.success(user: _currentUser!, token: _currentToken!);
    } catch (e) {
      print('Update profile error: $e');
      return AuthResult.failure('Failed to update profile. Please try again.');
    }
  }

  // Request password reset (placeholder for future email integration)
  Future<AuthResult> requestPasswordReset({required String email}) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      // Check if email exists
      final userData = await _dbService.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (userData.isEmpty) {
        return AuthResult.failure('No account found with this email address');
      }

      // In a real app, you would send an email with reset token
      // For now, we'll just return success
      return AuthResult.success(
        user: null,
        token: '',
        message: 'Password reset instructions have been sent to your email',
      );
    } catch (e) {
      print('Password reset error: $e');
      return AuthResult.failure('Failed to send password reset email');
    }
  }

  // Upgrade user role (for students upgrading to participant)
  Future<AuthResult> upgradeUserRole({
    required UserRole newRole,
    String? enrollmentNo,
    String? collegeId,
    String? department,
  }) async {
    try {
      if (_currentUser == null) {
        return AuthResult.failure('User not logged in');
      }

      // Validate role upgrade
      if (_currentUser!.role == UserRole.studentVisitor &&
          newRole == UserRole.studentParticipant) {
        // Require additional details for participant role
        if (enrollmentNo == null && collegeId == null) {
          return AuthResult.failure(
            'Enrollment number or College ID is required',
          );
        }

        // Update user role
        await _dbService.update(
          'users',
          {
            'role': newRole.value,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'user_id = ?',
          whereArgs: [_currentUser!.userId],
        );

        // Update user details if provided
        if (_currentUser!.details != null) {
          await _dbService.update(
            'user_details',
            {
              'enrollment_no':
                  enrollmentNo ?? _currentUser!.details!.enrollmentNo,
              'college_id': collegeId ?? _currentUser!.details!.collegeId,
              'department': department ?? _currentUser!.details!.department,
              'updated_at': DateTime.now().toIso8601String(),
            },
            where: 'user_id = ?',
            whereArgs: [_currentUser!.userId],
          );
        }

        // Reload user data
        await _loadUserFromStorage();

        return AuthResult.success(
          user: _currentUser!,
          token: _currentToken!,
          message: 'Account upgraded successfully!',
        );
      } else {
        return AuthResult.failure('Invalid role upgrade request');
      }
    } catch (e) {
      print('Role upgrade error: $e');
      return AuthResult.failure('Failed to upgrade account. Please try again.');
    }
  }

  // Check if user has permission
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;

    switch (permission) {
      case 'create_events':
        return _currentUser!.canCreateEvents;
      case 'register_events':
        return _currentUser!.canRegisterForEvents;
      case 'admin_access':
        return _currentUser!.isAdmin;
      case 'organizer_access':
        return _currentUser!.isOrganizer || _currentUser!.isAdmin;
      default:
        return false;
    }
  }

  // Dispose resources
  void dispose() {
    _userController.close();
  }
}

class AuthResult {
  final bool isSuccess;
  final String? message;
  final User? user;
  final String? token;

  AuthResult._(this.isSuccess, this.message, this.user, this.token);

  factory AuthResult.success({User? user, String? token, String? message}) {
    return AuthResult._(true, message, user, token);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(false, message, null, null);
  }
}
