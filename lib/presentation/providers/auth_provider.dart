import 'package:flutter/foundation.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  
  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String? _errorMessage;
  bool _isInitialized = false;
  
  // Getters
  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;
  bool get isLoading => _status == AuthStatus.loading;
  bool get hasError => _status == AuthStatus.error;
  
  // Role-based getters
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isOrganizer => _currentUser?.isOrganizer ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;
  bool get canCreateEvents => _currentUser?.canCreateEvents ?? false;
  bool get canRegisterForEvents => _currentUser?.canRegisterForEvents ?? false;
  
  AuthProvider() {
    _initializeAuth();
  }
  
  // Initialize authentication
  Future<void> _initializeAuth() async {
    try {
      // Simplified initialization for now
      await _authService.initialize();
      
      // Set initial status based on current user
      _currentUser = _authService.currentUser;
      if (_currentUser != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      _isInitialized = true;
      notifyListeners();
      debugPrint('Error initializing auth: $e');
    }
  }
  
  // Clear error message
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
  
  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      final result = await _authService.login(
        email: email,
        password: password,
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Login failed. Please try again.';
      notifyListeners();
      print('Login error: $e');
      return false;
    }
  }
  
  // Register user
  Future<bool> register({
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
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      final result = await _authService.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        fullName: fullName,
        mobileNumber: mobileNumber,
        department: department,
        enrollmentNo: enrollmentNo,
        collegeId: collegeId,
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Registration failed. Please try again.';
      notifyListeners();
      print('Registration error: $e');
      return false;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      print('AuthProvider: Starting logout...');
      _status = AuthStatus.loading;
      notifyListeners();
      
      await _authService.logout();
      
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      print('AuthProvider: Logout completed successfully');
    } catch (e) {
      print('AuthProvider: Logout error: $e');
      _status = AuthStatus.error;
      _errorMessage = 'Logout failed. Please try again.';
      notifyListeners();
    }
  }
  
  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.authenticated; // Keep authenticated state
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to change password. Please try again.';
      notifyListeners();
      print('Change password error: $e');
      return false;
    }
  }
  
  // Update profile
  Future<bool> updateProfile({
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
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      final result = await _authService.updateProfile(
        fullName: fullName,
        mobileNumber: mobileNumber,
        department: department,
        enrollmentNo: enrollmentNo,
        collegeId: collegeId,
        bio: bio,
        yearOfStudy: yearOfStudy,
        course: course,
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.authenticated; // Keep authenticated state
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to update profile. Please try again.';
      notifyListeners();
      print('Update profile error: $e');
      return false;
    }
  }
  
  // Request password reset
  Future<bool> requestPasswordReset({required String email}) async {
    try {
      _errorMessage = null;
      notifyListeners();
      
      final result = await _authService.requestPasswordReset(email: email);
      
      if (!result.isSuccess) {
        _errorMessage = result.message;
        notifyListeners();
      }
      
      return result.isSuccess;
    } catch (e) {
      _errorMessage = 'Failed to send password reset email.';
      notifyListeners();
      print('Password reset error: $e');
      return false;
    }
  }
  
  // Upgrade user role
  Future<bool> upgradeUserRole({
    required UserRole newRole,
    String? enrollmentNo,
    String? collegeId,
    String? department,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      final result = await _authService.upgradeUserRole(
        newRole: newRole,
        enrollmentNo: enrollmentNo,
        collegeId: collegeId,
        department: department,
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.authenticated; // Keep authenticated state
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to upgrade account. Please try again.';
      notifyListeners();
      print('Role upgrade error: $e');
      return false;
    }
  }
  
  // Check if user has permission
  bool hasPermission(String permission) {
    return _authService.hasPermission(permission);
  }
  
  // Get user display name
  String get displayName {
    if (_currentUser?.details?.fullName.isNotEmpty == true) {
      return _currentUser!.details!.fullName;
    }
    return _currentUser?.email.split('@').first ?? 'User';
  }
  
  // Get user initials
  String get userInitials {
    if (_currentUser?.details != null) {
      return _currentUser!.details!.initials;
    }
    final email = _currentUser?.email ?? '';
    return email.isNotEmpty ? email[0].toUpperCase() : 'U';
  }
  
  // Get user role display
  String get userRoleDisplay {
    switch (_currentUser?.role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.organizer:
        return 'Event Organizer';
      case UserRole.studentParticipant:
        return 'Student Participant';
      case UserRole.studentVisitor:
        return 'Student Visitor';
      case null:
        return 'Unknown';
    }
  }
  
  // Check if profile is complete
  bool get isProfileComplete {
    return _currentUser?.details?.isProfileComplete ?? false;
  }
  
  @override
    void dispose() {
      super.dispose();
    }
  }