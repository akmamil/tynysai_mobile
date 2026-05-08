// lib/core/models/patient_profile.dart

class PatientProfile {
  const PatientProfile({
    required this.id,         // Long in Java → int in Dart (safe)
    required this.userId,     // UUID String
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.middleName,
    this.phoneNumber,
    this.dateOfBirth,         // 'YYYY-MM-DD' string (Jackson LocalDate)
    this.age,
    this.gender,              // 'MALE' | 'FEMALE' | 'OTHER'
    this.bloodType,           // 'A_POSITIVE' etc.
    this.heightCm,
    this.weightKg,
    this.allergies,           // String, NOT List — confirmed from PatientProfileResponse.java
    this.chronicDiseases,     // String, NOT List
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
  final String? dateOfBirth;
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
  final String? profileCreatedAt;

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
      dateOfBirth: json['dateOfBirth'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      bloodType: json['bloodType'] as String?,
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
      profileCreatedAt: json['profileCreatedAt'] as String?,
    );
  }
}