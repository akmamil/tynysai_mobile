// lib/features/profile/presentation/providers/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/patient_profile.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/profile_remote_datasource.dart';

final profileDatasourceProvider = Provider.autoDispose<ProfileRemoteDatasource>((ref) {
  return ProfileRemoteDatasource(ref.watch(dioClientProvider).instance);
});

/// Loads PatientProfile once. Invalidate to force refresh:
///   ref.invalidate(patientProfileProvider)
final patientProfileProvider = FutureProvider.autoDispose<PatientProfile>((ref) {
  return ref.watch(profileDatasourceProvider).getPatientProfile();
});
