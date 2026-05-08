// lib/features/xray/data/mock_xray_state_machine.dart
//
// In-memory state machine that simulates the backend's async AI analysis flow.
// Only used when AppEnv.isMock == true.
//
// Lifecycle per upload:
//   0–2s after registerUpload()  → PENDING
//   2–8s after registerUpload()  → PROCESSING
//   8s+  after registerUpload()  → COMPLETED (with mock AI results)
//
// XrayDetailNotifier polls getXrayById() → which calls getState() here.
// The notifier is unaware this is a state machine — identical to real polling.

import '../../../core/models/xray_analysis.dart';
import '../../../core/models/enums.dart';

class MockXrayStateMachine {
  MockXrayStateMachine._();

  /// Singleton — one instance per app lifetime in mock mode.
  static final MockXrayStateMachine instance = MockXrayStateMachine._();

  // Maps xray ID → upload timestamp.
  final Map<int, _MockUpload> _uploads = {};
  int _nextId = 100;

  /// Registers a new upload and returns its mock ID.
  /// Called by XrayRemoteDatasource.uploadXray() in mock mode.
  int registerUpload({
    String? patientNotes,
    String? assignedDoctorId,
  }) {
    final id = _nextId++;
    _uploads[id] = _MockUpload(
      uploadedAt: DateTime.now(),
      patientNotes: patientNotes,
      assignedDoctorId: assignedDoctorId,
    );
    return id;
  }

  /// Returns the current XrayAnalysis state for a given ID based on
  /// elapsed time since upload. Returns null if the ID is unknown
  /// (i.e. it is a pre-seeded Postman ID — let the datasource fall through
  /// to the real HTTP call for those).
  XrayAnalysis? getState(int id) {
    final upload = _uploads[id];
    if (upload == null) return null;

    final elapsed = DateTime.now().difference(upload.uploadedAt);
    final status = _statusFor(elapsed);

    return XrayAnalysis(
      id: id,
      patientId: '00000000-0000-0000-0000-000000000001',
      patientName: 'Aizat Bekova',
      originalFileName: 'uploaded_xray.jpg',
      contentType: 'image/jpeg',
      fileSizeBytes: 524288,
      status: status,
      uploadedAt: upload.uploadedAt.toIso8601String(),
      patientNotes: upload.patientNotes,
      assignedDoctorId: upload.assignedDoctorId,
      assignedDoctorName: upload.assignedDoctorId != null
          ? 'Arman Bekovich Seitkali'
          : null,
      // AI fields — only populated when analysis completes.
      aiPrimaryDiagnosis: status == AnalysisStatus.completed
          ? DiseaseType.bacterialPneumonia
          : null,
      aiPrimaryDiagnosisDisplayName: status == AnalysisStatus.completed
          ? 'Bacterial Pneumonia'
          : null,
      aiConfidence: status == AnalysisStatus.completed ? 0.87 : null,
      aiFindings: status == AnalysisStatus.completed
          ? 'Consolidation in the right lower lobe consistent with bacterial pneumonia. No pleural effusion detected.'
          : null,
      aiDetectedAbnormalities: status == AnalysisStatus.completed
          ? 'Right lower lobe consolidation; Increased bronchial markings'
          : null,
      aiAllPredictionsJson: status == AnalysisStatus.completed
          ? '{"BACTERIAL_PNEUMONIA":0.87,"NORMAL":0.08,"VIRAL_PNEUMONIA":0.05}'
          : null,
      analyzedAt: status == AnalysisStatus.completed
          ? DateTime.now().toIso8601String()
          : null,
      // Doctor validation fields — never populated by mock upload.
      validatedByDoctorId: null,
      validatedByDoctorName: null,
      doctorDiagnosis: null,
      doctorDiagnosisDisplayName: null,
      doctorNotes: null,
      validatedAt: null,
    );
  }

  AnalysisStatus _statusFor(Duration elapsed) {
    if (elapsed.inSeconds < 2) return AnalysisStatus.pending;
    if (elapsed.inSeconds < 8) return AnalysisStatus.processing;
    return AnalysisStatus.completed;
  }
}

class _MockUpload {
  const _MockUpload({
    required this.uploadedAt,
    this.patientNotes,
    this.assignedDoctorId,
  });

  final DateTime uploadedAt;
  final String? patientNotes;
  final String? assignedDoctorId;
}