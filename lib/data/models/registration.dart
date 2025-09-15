import 'package:json_annotation/json_annotation.dart';
import 'common.dart';

part 'registration.g.dart';

// Registration Model
@JsonSerializable()
class Registration {
  final int id;
  final int userId;
  final int eventId;
  final RegistrationStatus status;
  final String? notes;
  final String? emergencyContact;
  final DateTime registeredAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  Registration({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    this.notes,
    this.emergencyContact,
    required this.registeredAt,
    this.approvedAt,
    this.approvedBy,
  });

  factory Registration.fromJson(Map<String, dynamic> json) => _$RegistrationFromJson(json);
  Map<String, dynamic> toJson() => _$RegistrationToJson(this);
}

// Registration Create Model
@JsonSerializable()
class RegistrationCreate {
  final int eventId;
  final String? notes;
  final String? emergencyContact;

  RegistrationCreate({
    required this.eventId,
    this.notes,
    this.emergencyContact,
  });

  factory RegistrationCreate.fromJson(Map<String, dynamic> json) => _$RegistrationCreateFromJson(json);
  Map<String, dynamic> toJson() => _$RegistrationCreateToJson(this);
}

// Registration Update Model
@JsonSerializable()
class RegistrationUpdate {
  final RegistrationStatus? status;
  final String? notes;
  final String? emergencyContact;

  RegistrationUpdate({
    this.status,
    this.notes,
    this.emergencyContact,
  });

  factory RegistrationUpdate.fromJson(Map<String, dynamic> json) => _$RegistrationUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$RegistrationUpdateToJson(this);
}
