// lib/core/models/user.dart

import 'enums.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    required this.enabled,
    required this.emailVerified,
    this.middleName,
    this.phoneNumber,
    this.avatarPath,
    this.createdAt,
  });

  final String id;           // UUID — always String, never int
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? middleName;
  final String? phoneNumber;
  final UserRole role;
  final bool enabled;
  final bool emailVerified;
  final String? avatarPath;
  final String? createdAt;   // ISO-8601, parse with DateTime.parse() at display layer

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String? ??
          '${json['firstName']} ${json['lastName']}',
      middleName: json['middleName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: _roleFromString(json['role'] as String?),
      enabled: json['enabled'] as bool? ?? true,
      emailVerified: json['emailVerified'] as bool? ?? false,
      avatarPath: json['avatarPath'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  static UserRole _roleFromString(String? s) => switch (s) {
        'ADMIN' => UserRole.admin,
        'DOCTOR' => UserRole.doctor,
        _ => UserRole.patient,
      };

  AppUser copyWith({
    String? fullName,
    String? phoneNumber,
    String? middleName,
    String? avatarPath,
  }) {
    return AppUser(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName ?? this.fullName,
      middleName: middleName ?? this.middleName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      enabled: enabled,
      emailVerified: emailVerified,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt,
    );
  }
}