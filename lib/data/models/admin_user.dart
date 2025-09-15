class AdminUser {
  final int id;
  final String username;
  final String email;
  final String role;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profileImageUrl;

  AdminUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.lastLogin,
    this.firstName,
    this.lastName,
    this.phone,
    this.profileImageUrl,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      firstName: json['user_details']?['first_name'],
      lastName: json['user_details']?['last_name'],
      phone: json['user_details']?['phone'],
      profileImageUrl: json['user_details']?['profile_image_url'],
    );
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'organizer':
        return 'Event Organizer';
      case 'student':
        return 'Student';
      default:
        return role.toUpperCase();
    }
  }
}
