class ApiConstants {
  static const String apiBaseUrl = 'https://fuse-back.onrender.com/api';

  // Auth Endpoints
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';

  // User Endpoints
  static const String usersEndpoint = '/users';
  static const String userProfileEndpoint = '/users/me';

  // Event Endpoints
  static const String eventsEndpoint = '/events';
  static const String eventSearchEndpoint = '/events/search';
  static const String eventCategoriesEndpoint = '/events/categories';
  static const String eventFeaturedEndpoint = '/events/featured';
  static const String eventUpcomingEndpoint = '/events/upcoming';

  // Registration Endpoints
  static const String registrationsEndpoint = '/registrations';

  // Feedback Endpoints
  static const String feedbackEndpoint = '/feedback';

  // Media Endpoints
  static const String mediaEndpoint = '/media';
  static const String mediaUploadEndpoint = '/media/upload';

  // SharedPreferences Keys
  static const String accessTokenKey = 'authToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userDataKey = 'userData';

  // Error Messages
  static const String validationErrorMessage = 'Validation failed. Please check your input.';
  static const String unauthorizedErrorMessage = 'Authentication failed. Please log in again.';
  static const String notFoundErrorMessage = 'The requested resource was not found.';
  static const String serverErrorMessage = 'An unexpected server error occurred.';
  static const String networkErrorMessage = 'Network error. Please check your internet connection.';
  static const String unknownErrorMessage = 'An unknown error occurred.';
}

// Custom Exception Classes
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Errors: $errors)';
  }
}

class NetworkException extends ApiException {
  NetworkException(super.message, {super.statusCode, super.errors});
}

class AuthException extends ApiException {
  AuthException(super.message, {super.statusCode, super.errors});
}

class ValidationException extends ApiException {
  ValidationException(super.message, {super.statusCode, super.errors});
}
