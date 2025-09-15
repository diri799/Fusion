// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Registration _$RegistrationFromJson(Map<String, dynamic> json) => Registration(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  eventId: (json['eventId'] as num).toInt(),
  status: $enumDecode(_$RegistrationStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
  emergencyContact: json['emergencyContact'] as String?,
  registeredAt: DateTime.parse(json['registeredAt'] as String),
  approvedAt:
      json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
  approvedBy: json['approvedBy'] as String?,
);

Map<String, dynamic> _$RegistrationToJson(Registration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'eventId': instance.eventId,
      'status': _$RegistrationStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'emergencyContact': instance.emergencyContact,
      'registeredAt': instance.registeredAt.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'approvedBy': instance.approvedBy,
    };

const _$RegistrationStatusEnumMap = {
  RegistrationStatus.pending: 'pending',
  RegistrationStatus.confirmed: 'confirmed',
  RegistrationStatus.cancelled: 'cancelled',
  RegistrationStatus.attended: 'attended',
  RegistrationStatus.noShow: 'no_show',
};

RegistrationCreate _$RegistrationCreateFromJson(Map<String, dynamic> json) =>
    RegistrationCreate(
      eventId: (json['eventId'] as num).toInt(),
      notes: json['notes'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
    );

Map<String, dynamic> _$RegistrationCreateToJson(RegistrationCreate instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'notes': instance.notes,
      'emergencyContact': instance.emergencyContact,
    };

RegistrationUpdate _$RegistrationUpdateFromJson(Map<String, dynamic> json) =>
    RegistrationUpdate(
      status: $enumDecodeNullable(_$RegistrationStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
    );

Map<String, dynamic> _$RegistrationUpdateToJson(RegistrationUpdate instance) =>
    <String, dynamic>{
      'status': _$RegistrationStatusEnumMap[instance.status],
      'notes': instance.notes,
      'emergencyContact': instance.emergencyContact,
    };
