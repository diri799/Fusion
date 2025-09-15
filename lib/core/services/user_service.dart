import 'api_service.dart';
import '../constants/api_constants.dart';
import '../../data/models/user.dart';
import '../../data/models/common.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiService _apiService = ApiService.instance;

  // Get all users (admin only)
  Future<PaginatedResponse<User>> getUsers({int page = 1, int size = 10}) async {
    try {
      // Since ApiService doesn't have getUsers, we'll need to implement this
      // For now, we'll throw an exception indicating this feature needs backend support
      throw ApiException('Get all users feature requires backend support. Please contact administrator.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch users: $e');
    }
  }

  // Get user by ID
  Future<User> getUserById(int id) async {
    try {
      // Since ApiService doesn't have getUserById, we'll need to implement this
      // For now, we'll throw an exception indicating this feature needs backend support
      throw ApiException('Get user by ID feature requires backend support. Please contact administrator.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch user: $e');
    }
  }

  // Get current user profile
  Future<User> getCurrentUserProfile() async {
    try {
      final response = await _apiService.getCurrentUser();
      return User.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch current user profile: $e');
    }
  }

  // Update user profile
  Future<User> updateUserProfile(UserUpdate userData) async {
    try {
      final response = await _apiService.updateUserDetails(userData.toJson());
      return User.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update user profile: $e');
    }
  }

  // Update user (admin only)
  Future<User> updateUser(int id, UserUpdate userData) async {
    try {
      // Since ApiService doesn't have updateUser by ID, we'll need to implement this
      // For now, we'll throw an exception indicating this feature needs backend support
      throw ApiException('Update user by ID feature requires backend support. Please contact administrator.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update user: $e');
    }
  }

  // Delete user (admin only)
  Future<void> deleteUser(int id) async {
    try {
      // Since ApiService doesn't have deleteUser, we'll need to implement this
      // For now, we'll throw an exception indicating this feature needs backend support
      throw ApiException('Delete user feature requires backend support. Please contact administrator.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to delete user: $e');
    }
  }

  // Get users by role
  Future<PaginatedResponse<User>> getUsersByRole(UserRole role, {int page = 1, int size = 10}) async {
    try {
      // Since ApiService doesn't have getUsersByRole, we'll need to implement this
      // For now, we'll throw an exception indicating this feature needs backend support
      throw ApiException('Get users by role feature requires backend support. Please contact administrator.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch users by role: $e');
    }
  }
}
