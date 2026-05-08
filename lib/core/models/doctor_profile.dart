// lib/core/models/doctor_profile.dart

class DoctorProfile {
  const DoctorProfile({
    required this.id,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.middleName,
    this.phoneNumber,
    this.specialization,
    this.licenseNumber,
    this.hospitalName,
    this.department,
    this.yearsOfExperience,
    this.bio,
    this.education,
    required this.approved,
    this.workSchedule,        // ← Map, not String
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
  final String? specialization;
  final String? licenseNumber;
  final String? hospitalName;
  final String? department;
  final int? yearsOfExperience;
  final String? bio;
  final String? education;
  final bool approved;
  // Backend: Map<DayOfWeek, List<TimeRange>> — arrives as nested JSON object.
  // Typed as Map<String, dynamic>? so it never crashes on any server shape.
  final Map<String, dynamic>? workSchedule;
  final String? profileCreatedAt;

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] as int,
      userId: json['userId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String? ??
          '${json['firstName']} ${json['lastName']}',
      middleName: json['middleName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      specialization: json['specialization'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      hospitalName: json['hospitalName'] as String?,
      department: json['department'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      bio: json['bio'] as String?,
      education: json['education'] as String?,
      approved: json['approved'] as bool? ?? false,
      // Handles both the mock (String) and production (Map) gracefully.
      // The mock currently sends a String — this cast returns null for it,
      // which is safe. Fix the mock to send a Map when building the
      // doctor-availability UI.
      workSchedule: json['workSchedule'] is Map
          ? Map<String, dynamic>.from(json['workSchedule'] as Map)
          : null,
      profileCreatedAt: json['profileCreatedAt'] as String?,
    );
  }
}