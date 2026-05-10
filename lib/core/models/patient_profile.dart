// lib/core/models/patient_profile.dart

class PatientProfile {
  const PatientProfile({
    required this.id,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.middleName,
    this.phoneNumber,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.bloodType,
    this.heightCm,
    this.weightKg,
    this.allergies,
    this.chronicDiseases,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.address,
    this.insuranceNumber,
    this.occupation,
    this.smoker,
    this.alcoholUser,
    this.medicalHistory,
    this.profileCreatedAt,
  });

  final int id;
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? middleName;
  final String? phoneNumber;
  final String? dateOfBirth;        // 'YYYY-MM-DD' string OR [year,month,day] array from real backend
  final int? age;
  final String? gender;
  final String? bloodType;
  final double? heightCm;
  final double? weightKg;
  final String? allergies;
  final String? chronicDiseases;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? address;
  final String? insuranceNumber;
  final String? occupation;
  final bool? smoker;
  final bool? alcoholUser;
  final String? medicalHistory;
  final String? profileCreatedAt;   // ISO-8601 string OR [year,month,day,h,m,s] array from real backend

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as int,
      userId: json['userId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String? ??
          '${json['firstName']} ${json['lastName']}',
      middleName: json['middleName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      // ── DEFENSIVE DATE PARSING ───────────────────────────────────────────
      // Spring Boot serializes LocalDate as either:
      //   A) "1990-05-15" (string) — when WRITE_DATES_AS_TIMESTAMPS=false
      //   B) [1990, 5, 15] (array) — Jackson default WITHOUT config
      //
      // The Postman mock returns format A (string).
      // The real backend (without explicit Jackson config) returns format B (array).
      //
      // _parseDate() handles both formats transparently.
      // When production backend is connected, this prevents the crash:
      //   "type 'List' is not a subtype of type 'String?'"
      // ─────────────────────────────────────────────────────────────────────
      dateOfBirth: _parseDate(json['dateOfBirth']),
      age: json['age'] as int?,
      gender: _parseEnumString(json['gender']),
      bloodType: _parseEnumString(json['bloodType']),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      allergies: json['allergies'] as String?,
      chronicDiseases: json['chronicDiseases'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      address: json['address'] as String?,
      insuranceNumber: json['insuranceNumber'] as String?,
      occupation: json['occupation'] as String?,
      smoker: json['smoker'] as bool?,
      alcoholUser: json['alcoholUser'] as bool?,
      medicalHistory: json['medicalHistory'] as String?,
      // profileCreatedAt is LocalDateTime → may arrive as [2024,1,15,10,30,0]
      profileCreatedAt: _parseDateTime(json['profileCreatedAt']),
    );
  }
}

// ── Private date helpers ───────────────────────────────────────────────────
//
// Handles two Jackson serialization formats for Java time types:
//
//   LocalDate (dateOfBirth):
//     String form:  "1990-05-15"
//     Array form:   [1990, 5, 15]
//
//   LocalDateTime (profileCreatedAt):
//     String form:  "2024-01-15T10:30:00"  or  "2024-01-15T10:30:00Z"
//     Array form:   [2024, 1, 15, 10, 30, 0]  or  [2024, 1, 15, 10, 30, 0, 0]
// ─────────────────────────────────────────────────────────────────────────

/// Converts a LocalDate value (String or List) to an ISO-8601 date string.
/// Returns null if the value is null or unrecognisable.
String? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is String) return value; // already "YYYY-MM-DD"
  if (value is List && value.length >= 3) {
    // [year, month, day]
    final y = value[0].toString();
    final m = value[1].toString().padLeft(2, '0');
    final d = value[2].toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
  return null;
}

/// Converts a LocalDateTime value (String or List) to an ISO-8601 datetime string.
/// Returns null if the value is null or unrecognisable.
String? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return value; // already ISO string
  if (value is List && value.length >= 3) {
    // [year, month, day] or [year, month, day, hour, min, sec, nano]
    final y = value[0].toString();
    final mo = value[1].toString().padLeft(2, '0');
    final d = value[2].toString().padLeft(2, '0');
    if (value.length >= 6) {
      final h = value[3].toString().padLeft(2, '0');
      final mi = value[4].toString().padLeft(2, '0');
      final s = value[5].toString().padLeft(2, '0');
      return '$y-$mo-${d}T$h:$mi:${s}Z';
    }
    return '$y-$mo-${d}T00:00:00Z';
  }
  return null;
}

/// Enum fields (Gender, BloodType) arrive as plain strings from both
/// Spring Boot and Postman. Safe cast — no defensive handling needed.
String? _parseEnumString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}