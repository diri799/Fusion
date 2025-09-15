// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  username: json['username'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'role': _$UserRoleEnumMap[instance.role]!,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.student: 'student',
  UserRole.organizer: 'organizer',
  UserRole.admin: 'admin',
};

UserCreate _$UserCreateFromJson(Map<String, dynamic> json) => UserCreate(
  email: json['email'] as String,
  username: json['username'] as String,
  password: json['password'] as String,
  role:
      $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.student,
);

Map<String, dynamic> _$UserCreateToJson(UserCreate instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'password': instance.password,
      'role': _$UserRoleEnumMap[instance.role]!,
    };

UserUpdate _$UserUpdateFromJson(Map<String, dynamic> json) => UserUpdate(
  email: json['email'] as String?,
  username: json['username'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$UserUpdateToJson(UserUpdate instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'isActive': instance.isActive,
    };

UserDetails _$UserDetailsFromJson(Map<String, dynamic> json) => UserDetails(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  collegeName: json['collegeName'] as String?,
  department: json['department'] as String?,
  yearOfStudy: json['yearOfStudy'] as String?,
  studentId: json['studentId'] as String?,
  bio: json['bio'] as String?,
  profilePictureUrl: json['profilePictureUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserDetailsToJson(UserDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'collegeName': instance.collegeName,
      'department': instance.department,
      'yearOfStudy': instance.yearOfStudy,
      'studentId': instance.studentId,
      'bio': instance.bio,
      'profilePictureUrl': instance.profilePictureUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

UserDetailsCreate _$UserDetailsCreateFromJson(Map<String, dynamic> json) =>
    UserDetailsCreate(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      collegeName: json['collegeName'] as String?,
      department: json['department'] as String?,
      yearOfStudy: json['yearOfStudy'] as String?,
      studentId: json['studentId'] as String?,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );

Map<String, dynamic> _$UserDetailsCreateToJson(UserDetailsCreate instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'collegeName': instance.collegeName,
      'department': instance.department,
      'yearOfStudy': instance.yearOfStudy,
      'studentId': instance.studentId,
      'bio': instance.bio,
      'profilePictureUrl': instance.profilePictureUrl,
    };

UserDetailsUpdate _$UserDetailsUpdateFromJson(Map<String, dynamic> json) =>
    UserDetailsUpdate(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      collegeName: json['collegeName'] as String?,
      department: json['department'] as String?,
      yearOfStudy: json['yearOfStudy'] as String?,
      studentId: json['studentId'] as String?,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );

Map<String, dynamic> _$UserDetailsUpdateToJson(UserDetailsUpdate instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'collegeName': instance.collegeName,
      'department': instance.department,
      'yearOfStudy': instance.yearOfStudy,
      'studentId': instance.studentId,
      'bio': instance.bio,
      'profilePictureUrl': instance.profilePictureUrl,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'tokenType': instance.tokenType,
      'user': instance.user,
    };
