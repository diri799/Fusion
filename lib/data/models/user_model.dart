import 'package:uuid/uuid.dart';

enum UserRole {
  studentVisitor('student_visitor'),
  studentParticipant('student_participant'),
  organizer('organizer'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.studentVisitor,
    );
  }
}

class User {
  final String userId;
  final String email;
  final String password;
  final UserRole role;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserDetails? details;

  User({
    required this.userId,
    required this.email,
    required this.password,
    required this.role,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.details,
  });

  factory User.create({
    required String email,
    required String password,
    required UserRole role,
  }) {
    final now = DateTime.now();
    return User(
      userId: const Uuid().v4(),
      email: email,
      password: password,
      role: role,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'student_visitor'),
      isActive: (map['is_active'] ?? 1) == 1,
      isVerified: (map['is_verified'] ?? 0) == 1,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  factory User.fromApiResponse(Map<String, dynamic> apiData) {
    // Extract user name from API response - could be 'user_name' or 'username'
    final userName = apiData['user_name'] ?? apiData['username'] ?? '';
    
    // Create UserDetails with the username if no user_details are provided
    UserDetails? details;
    if (apiData['user_details'] != null) {
      details = UserDetails.fromApiResponse(apiData['user_details']);
    } else if (userName.isNotEmpty) {
      // Create basic UserDetails with the username as full name
      details = UserDetails.create(
        userId: apiData['id']?.toString() ?? '',
        fullName: userName,
      );
    }
    
    return User(
      userId: apiData['id']?.toString() ?? '',
      email: apiData['email'] ?? '',
      password: '', // Don't store password from API
      role: UserRole.fromString(apiData['role'] ?? 'student_visitor'),
      isActive: apiData['is_active'] ?? true,
      isVerified: true, // Assume verified if from API
      createdAt:
          DateTime.tryParse(apiData['created_at'] ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(apiData['updated_at'] ?? '') ?? DateTime.now(),
      details: details,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'email': email,
      'password': password,
      'role': role.value,
      'is_active': isActive ? 1 : 0,
      'is_verified': isVerified ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? userId,
    String? email,
    String? password,
    UserRole? role,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserDetails? details,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      details: details ?? this.details,
    );
  }

  bool get canCreateEvents =>
      role == UserRole.organizer || role == UserRole.admin;
  bool get canRegisterForEvents => role == UserRole.studentParticipant;
  bool get isAdmin => role == UserRole.admin;
  bool get isOrganizer => role == UserRole.organizer;
  bool get isStudent =>
      role == UserRole.studentVisitor || role == UserRole.studentParticipant;

  @override
  String toString() {
    return 'User(userId: $userId, email: $email, role: ${role.value}, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

class UserDetails {
  final String detailId;
  final String userId;
  final String fullName;
  final String? mobileNumber;
  final String? department;
  final String? enrollmentNo;
  final String? collegeId;
  final String? profilePicUrl;
  final String? bio;
  final int? yearOfStudy;
  final String? course;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserDetails({
    required this.detailId,
    required this.userId,
    required this.fullName,
    this.mobileNumber,
    this.department,
    this.enrollmentNo,
    this.collegeId,
    this.profilePicUrl,
    this.bio,
    this.yearOfStudy,
    this.course,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDetails.create({
    required String userId,
    required String fullName,
    String? mobileNumber,
    String? department,
    String? enrollmentNo,
    String? collegeId,
    String? profilePicUrl,
    String? bio,
    int? yearOfStudy,
    String? course,
  }) {
    final now = DateTime.now();
    return UserDetails(
      detailId: const Uuid().v4(),
      userId: userId,
      fullName: fullName,
      mobileNumber: mobileNumber,
      department: department,
      enrollmentNo: enrollmentNo,
      collegeId: collegeId,
      profilePicUrl: profilePicUrl,
      bio: bio,
      yearOfStudy: yearOfStudy,
      course: course,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      detailId: map['detail_id'] ?? '',
      userId: map['user_id'] ?? '',
      fullName: map['full_name'] ?? '',
      mobileNumber: map['mobile_number'],
      department: map['department'],
      enrollmentNo: map['enrollment_no'],
      collegeId: map['college_id'],
      profilePicUrl: map['profile_pic_url'],
      bio: map['bio'],
      yearOfStudy: map['year_of_study'],
      course: map['course'],
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  factory UserDetails.fromApiResponse(Map<String, dynamic> apiData) {
    return UserDetails(
      detailId: apiData['id']?.toString() ?? '',
      userId: apiData['user_id']?.toString() ?? '',
      fullName:
          apiData['first_name'] ?? '' + ' ' + (apiData['last_name'] ?? ''),
      mobileNumber: apiData['phone_number'],
      department: apiData['department'],
      enrollmentNo: apiData['student_id'],
      collegeId: apiData['college_name'],
      profilePicUrl: apiData['profile_picture_url'],
      bio: apiData['bio'],
      yearOfStudy:
          apiData['year_of_study'] != null
              ? int.tryParse(apiData['year_of_study'].toString())
              : null,
      course: null, // Not in API response
      createdAt:
          DateTime.tryParse(apiData['created_at'] ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(apiData['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'detail_id': detailId,
      'user_id': userId,
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'department': department,
      'enrollment_no': enrollmentNo,
      'college_id': collegeId,
      'profile_pic_url': profilePicUrl,
      'bio': bio,
      'year_of_study': yearOfStudy,
      'course': course,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserDetails copyWith({
    String? detailId,
    String? userId,
    String? fullName,
    String? mobileNumber,
    String? department,
    String? enrollmentNo,
    String? collegeId,
    String? profilePicUrl,
    String? bio,
    int? yearOfStudy,
    String? course,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserDetails(
      detailId: detailId ?? this.detailId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      department: department ?? this.department,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      collegeId: collegeId ?? this.collegeId,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      bio: bio ?? this.bio,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      course: course ?? this.course,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => fullName;
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }

  bool get isProfileComplete {
    return fullName.isNotEmpty &&
        mobileNumber != null &&
        department != null &&
        (enrollmentNo != null || collegeId != null);
  }

  @override
  String toString() {
    return 'UserDetails(detailId: $detailId, fullName: $fullName, department: $department)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDetails && other.detailId == detailId;
  }

  @override
  int get hashCode => detailId.hashCode;
}

class UserPreferences {
  final String preferenceId;
  final String userId;
  final bool notificationEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool eventReminders;
  final bool newsletterSubscription;
  final List<String> preferredCategories;
  final String themePreference;
  final String languagePreference;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.preferenceId,
    required this.userId,
    this.notificationEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.eventReminders = true,
    this.newsletterSubscription = false,
    this.preferredCategories = const [],
    this.themePreference = 'system',
    this.languagePreference = 'en',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.create({required String userId}) {
    final now = DateTime.now();
    return UserPreferences(
      preferenceId: const Uuid().v4(),
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      preferenceId: map['preference_id'] ?? '',
      userId: map['user_id'] ?? '',
      notificationEnabled: (map['notification_enabled'] ?? 1) == 1,
      emailNotifications: (map['email_notifications'] ?? 1) == 1,
      pushNotifications: (map['push_notifications'] ?? 1) == 1,
      eventReminders: (map['event_reminders'] ?? 1) == 1,
      newsletterSubscription: (map['newsletter_subscription'] ?? 0) == 1,
      preferredCategories:
          (map['preferred_categories'] as String?)?.split(',') ?? [],
      themePreference: map['theme_preference'] ?? 'system',
      languagePreference: map['language_preference'] ?? 'en',
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preference_id': preferenceId,
      'user_id': userId,
      'notification_enabled': notificationEnabled ? 1 : 0,
      'email_notifications': emailNotifications ? 1 : 0,
      'push_notifications': pushNotifications ? 1 : 0,
      'event_reminders': eventReminders ? 1 : 0,
      'newsletter_subscription': newsletterSubscription ? 1 : 0,
      'preferred_categories': preferredCategories.join(','),
      'theme_preference': themePreference,
      'language_preference': languagePreference,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserPreferences copyWith({
    String? preferenceId,
    String? userId,
    bool? notificationEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? eventReminders,
    bool? newsletterSubscription,
    List<String>? preferredCategories,
    String? themePreference,
    String? languagePreference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      preferenceId: preferenceId ?? this.preferenceId,
      userId: userId ?? this.userId,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      eventReminders: eventReminders ?? this.eventReminders,
      newsletterSubscription:
          newsletterSubscription ?? this.newsletterSubscription,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      themePreference: themePreference ?? this.themePreference,
      languagePreference: languagePreference ?? this.languagePreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
