import 'package:json_annotation/json_annotation.dart';
import 'common.dart';

part 'user.g.dart';

// User Model
@JsonSerializable()
class User {
  final int id;
  final String email;
  final String username;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// User Create Model
@JsonSerializable()
class UserCreate {
  final String email;
  final String username;
  final String password;
  final UserRole role;

  UserCreate({
    required this.email,
    required this.username,
    required this.password,
    this.role = UserRole.student,
  });

  factory UserCreate.fromJson(Map<String, dynamic> json) => _$UserCreateFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreateToJson(this);
}

// User Update Model
@JsonSerializable()
class UserUpdate {
  final String? email;
  final String? username;
  final bool? isActive;

  UserUpdate({
    this.email,
    this.username,
    this.isActive,
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) => _$UserUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$UserUpdateToJson(this);
}

// User Details Model
@JsonSerializable()
class UserDetails {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? collegeName;
  final String? department;
  final String? yearOfStudy;
  final String? studentId;
  final String? bio;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserDetails({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.collegeName,
    this.department,
    this.yearOfStudy,
    this.studentId,
    this.bio,
    this.profilePictureUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => _$UserDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$UserDetailsToJson(this);
}

// User Details Create Model
@JsonSerializable()
class UserDetailsCreate {
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? collegeName;
  final String? department;
  final String? yearOfStudy;
  final String? studentId;
  final String? bio;
  final String? profilePictureUrl;

  UserDetailsCreate({
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.collegeName,
    this.department,
    this.yearOfStudy,
    this.studentId,
    this.bio,
    this.profilePictureUrl,
  });

  factory UserDetailsCreate.fromJson(Map<String, dynamic> json) => _$UserDetailsCreateFromJson(json);
  Map<String, dynamic> toJson() => _$UserDetailsCreateToJson(this);
}

// User Details Update Model
@JsonSerializable()
class UserDetailsUpdate {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? collegeName;
  final String? department;
  final String? yearOfStudy;
  final String? studentId;
  final String? bio;
  final String? profilePictureUrl;

  UserDetailsUpdate({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.collegeName,
    this.department,
    this.yearOfStudy,
    this.studentId,
    this.bio,
    this.profilePictureUrl,
  });

  factory UserDetailsUpdate.fromJson(Map<String, dynamic> json) => _$UserDetailsUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$UserDetailsUpdateToJson(this);
}

// Login Request Model
@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

// Login Response Model
@JsonSerializable()
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
