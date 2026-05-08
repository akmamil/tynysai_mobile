// lib/features/profile/data/profile_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../core/config/app_env.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/models/patient_profile.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_exception.dart';

class ProfileRemoteDatasource {
  ProfileRemoteDatasource(this._dio);
  final Dio _dio;

  Future<AppUser> getMe() async {
    try {
      final response = await _dio.get(ApiPaths.getMe);
      final body = response.data as Map<String, dynamic>;
      return AppUser.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<PatientProfile> getPatientProfile() async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockPatientProfile;
    }
    try {
      final response = await _dio.get(ApiPaths.getMyPatientProfile);
      final body = response.data as Map<String, dynamic>;
      return PatientProfile.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<PatientProfile> updatePatientProfile(Map<String, dynamic> updates) async {
    if (AppEnv.isMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockPatientProfile;
    }
    try {
      final response = await _dio.put(
        ApiPaths.updateMyPatientProfile,
        data: updates,
      );
      final body = response.data as Map<String, dynamic>;
      return PatientProfile.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

// Matches the Postman mock response exactly — same data, no network needed.
const _mockPatientProfile = PatientProfile(
  id: 1,
  userId: '00000000-0000-0000-0000-000000000001',
  email: 'patient@tynysai.kz',
  firstName: 'Aizat',
  lastName: 'Bekova',
  middleName: null,
  fullName: 'Aizat Bekova',
  phoneNumber: '+7 701 234 5678',
  dateOfBirth: '1990-05-15',
  age: 34,
  gender: 'FEMALE',
  bloodType: 'A_POSITIVE',
  heightCm: 165,
  weightKg: 58.5,
  allergies: 'None known',
  chronicDiseases: null,
  emergencyContactName: 'Bekova Gulnara',
  emergencyContactPhone: '+7 702 345 6789',
  address: 'Almaty, Kazakhstan',
  insuranceNumber: 'INS-2024-001',
  occupation: 'Teacher',
  smoker: false,
  alcoholUser: false,
  medicalHistory: null,
  profileCreatedAt: '2024-01-15T10:30:00Z',
);