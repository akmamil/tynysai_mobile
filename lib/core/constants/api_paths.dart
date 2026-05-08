class ApiPaths {
  ApiPaths._();

  // ── Auth (no Bearer needed) ───────────────────────────
  static const registerPatient = '/api/auth/register/patient';

  // ── Users ─────────────────────────────────────────────
  static const getMe = '/api/users/me';
  static const updateMe = '/api/users/me';
  static const changePassword = '/api/users/me/password';
  static const uploadAvatar = '/api/users/me/avatar';
  static const deleteAvatar = '/api/users/me/avatar';
  static String getAvatar(String userId) => '/api/users/$userId/avatar';

  // ── Patients ──────────────────────────────────────────
  static const getMyPatientProfile = '/api/patients/me';
  static const updateMyPatientProfile = '/api/patients/me';

  // ── Doctors ───────────────────────────────────────────
  static const approvedDoctors = '/api/doctors/approved';

  // ── XRays ─────────────────────────────────────────────
  static const patientUploadXray = '/api/xrays/patient/upload';
  static const getPatientXrays = '/api/xrays/patient';
  static String getXrayById(int id) => '/api/xrays/$id';
  static String deleteXray(int id) => '/api/xrays/$id';

  // ── Notifications ─────────────────────────────────────
  static const getNotifications = '/api/notifications';
  static String markNotificationRead(int id) => '/api/notifications/$id/read';
}