// lib/core/constants/api_paths.dart

class ApiPaths {
  ApiPaths._();

  // ── Auth (no Bearer needed) ───────────────────────────
  static const registerPatient = '/api/auth/register/patient';

  // ── Users ─────────────────────────────────────────────
  static const getMe           = '/api/users/me';
  static const updateMe        = '/api/users/me';
  static const changePassword  = '/api/users/me/password';
  static const uploadAvatar    = '/api/users/me/avatar';
  static const deleteAvatar    = '/api/users/me/avatar';
  static String getAvatar(String userId) => '/api/users/$userId/avatar';

  // ── Patients ──────────────────────────────────────────
  static const getMyPatientProfile    = '/api/patients/me';
  static const updateMyPatientProfile = '/api/patients/me';

  // ── Doctors ───────────────────────────────────────────
  static const approvedDoctors = '/api/doctors/approved';

  // ── XRays ─────────────────────────────────────────────
  static const patientUploadXray = '/api/xrays/patient/upload';
  static const getPatientXrays   = '/api/xrays/patient';
  static String getXrayById(int id)  => '/api/xrays/$id';
  static String deleteXray(int id)   => '/api/xrays/$id';

  // ── Notifications ─────────────────────────────────────
  static const getNotifications = '/api/notifications';
  static String markNotificationRead(int id) =>
      '/api/notifications/$id/read';

  // ── Reports (medical-record-service) ──────────────────
  // Patient-scoped list: returns PageResponse<DiagnosticReportResponse>
  static const getPatientReports = '/api/reports/patient';
  static String getReportByIdForPatient(int id) => '/api/reports/patient/$id';
  static String getReportByIdForDoctor(int id)  => '/api/reports/doctor/$id';


  static const getPatientLabResults = '/api/lab-results/patient';
  static String getLabResultById(int id) => '/api/lab-results/patient/$id';
  static const getPatientAppointments = '/api/appointments/patient';
  static const bookAppointment = '/api/appointments';
  static String cancelAppointment(int id) => '/api/appointments/$id/cancel';
  static const getDoctorAssignedXrays = '/api/xrays/doctor/assigned';
  static String validateXray(int id) => '/api/xrays/$id/validate';
  static const getDoctorProfile = '/api/doctors/me';
  static const updateDoctorProfile = '/api/doctors/me';
}