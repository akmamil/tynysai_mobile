// lib/core/models/enums.dart

enum UserRole { patient, doctor, admin }

enum AnalysisStatus {
  pending,
  processing,
  completed,
  requiresReview,
  validated,
  failed,
}

enum DiseaseType {
  normal,
  bacterialPneumonia,
  viralPneumonia,
  covid19,
  tuberculosis,
  copd,
  lungCancer,
  pleuralEffusion,
  pneumothorax,
  pulmonaryFibrosis,
  atelectasis,
  cardiomegaly,
  edema,
  other,
}

enum Severity { none, mild, moderate, severe, critical }

extension AnalysisStatusX on AnalysisStatus {
  bool get isTerminal =>
      this == AnalysisStatus.completed ||
      this == AnalysisStatus.validated ||
      this == AnalysisStatus.failed;

  bool get isProcessing =>
      this == AnalysisStatus.pending || this == AnalysisStatus.processing;

  String get displayName => switch (this) {
        AnalysisStatus.pending => 'Pending',
        AnalysisStatus.processing => 'Processing',
        AnalysisStatus.completed => 'Completed',
        AnalysisStatus.requiresReview => 'Requires Review',
        AnalysisStatus.validated => 'Validated',
        AnalysisStatus.failed => 'Failed',
      };
}

extension DiseaseTypeX on DiseaseType {
  String get displayName => switch (this) {
        DiseaseType.normal => 'Normal',
        DiseaseType.bacterialPneumonia => 'Bacterial Pneumonia',
        DiseaseType.viralPneumonia => 'Viral Pneumonia',
        DiseaseType.covid19 => 'COVID-19',
        DiseaseType.tuberculosis => 'Tuberculosis',
        DiseaseType.copd => 'COPD',
        DiseaseType.lungCancer => 'Lung Cancer',
        DiseaseType.pleuralEffusion => 'Pleural Effusion',
        DiseaseType.pneumothorax => 'Pneumothorax',
        DiseaseType.pulmonaryFibrosis => 'Pulmonary Fibrosis',
        DiseaseType.atelectasis => 'Atelectasis',
        DiseaseType.cardiomegaly => 'Cardiomegaly',
        DiseaseType.edema => 'Edema',
        DiseaseType.other => 'Other',
      };
}

// JSON deserializers (match backend enum string values exactly)
AnalysisStatus analysisStatusFromJson(String? s) => switch (s) {
      'PENDING' => AnalysisStatus.pending,
      'PROCESSING' => AnalysisStatus.processing,
      'COMPLETED' => AnalysisStatus.completed,
      'REQUIRES_REVIEW' => AnalysisStatus.requiresReview,
      'VALIDATED' => AnalysisStatus.validated,
      'FAILED' => AnalysisStatus.failed,
      _ => AnalysisStatus.failed,
    };

DiseaseType? diseaseTypeFromJson(String? s) => switch (s) {
      'NORMAL' => DiseaseType.normal,
      'BACTERIAL_PNEUMONIA' => DiseaseType.bacterialPneumonia,
      'VIRAL_PNEUMONIA' => DiseaseType.viralPneumonia,
      'COVID_19' => DiseaseType.covid19,
      'TUBERCULOSIS' => DiseaseType.tuberculosis,
      'COPD' => DiseaseType.copd,
      'LUNG_CANCER' => DiseaseType.lungCancer,
      'PLEURAL_EFFUSION' => DiseaseType.pleuralEffusion,
      'PNEUMOTHORAX' => DiseaseType.pneumothorax,
      'PULMONARY_FIBROSIS' => DiseaseType.pulmonaryFibrosis,
      'ATELECTASIS' => DiseaseType.atelectasis,
      'CARDIOMEGALY' => DiseaseType.cardiomegaly,
      'EDEMA' => DiseaseType.edema,
      'OTHER' => DiseaseType.other,
      _ => null,
    };

extension UserRoleX on UserRole {
  String get displayName => switch (this) {
    UserRole.patient => 'Patient',
    UserRole.doctor  => 'Doctor',
    UserRole.admin   => 'Admin',
  };
}

UserRole userRoleFromRealmRoles(List<String> roles) {
  if (roles.contains('ADMIN')) return UserRole.admin;
  if (roles.contains('DOCTOR')) return UserRole.doctor;
  return UserRole.patient;
}