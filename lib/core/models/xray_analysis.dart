// lib/core/models/xray_analysis.dart

import 'enums.dart';

class XrayAnalysis {
  const XrayAnalysis({
    required this.id,
    required this.patientId,
    required this.originalFileName,
    required this.contentType,
    required this.status,
    required this.uploadedAt,
    this.patientName,
    this.assignedDoctorId,
    this.assignedDoctorName,
    this.fileSizeBytes,
    this.aiPrimaryDiagnosis,
    this.aiPrimaryDiagnosisDisplayName,
    this.aiConfidence,
    this.aiFindings,
    this.aiDetectedAbnormalities,
    this.aiAllPredictionsJson,   // ← NEW
    this.validatedByDoctorId,
    this.validatedByDoctorName,
    this.doctorDiagnosis,
    this.doctorDiagnosisDisplayName,
    this.doctorNotes,
    this.validatedAt,
    this.patientNotes,
    this.analyzedAt,
  });

  final int id;
  final String patientId;
  final String? patientName;
  final String? assignedDoctorId;
  final String? assignedDoctorName;
  final String originalFileName;
  final String contentType;
  final int? fileSizeBytes;
  final AnalysisStatus status;
  final DiseaseType? aiPrimaryDiagnosis;
  final String? aiPrimaryDiagnosisDisplayName;
  final double? aiConfidence;
  final String? aiFindings;
  final String? aiDetectedAbnormalities;
  final String? aiAllPredictionsJson;  // ← NEW
  final String? validatedByDoctorId;
  final String? validatedByDoctorName;
  final DiseaseType? doctorDiagnosis;
  final String? doctorDiagnosisDisplayName;
  final String? doctorNotes;
  final String? validatedAt;
  final String? patientNotes;
  final String uploadedAt;
  final String? analyzedAt;

  factory XrayAnalysis.fromJson(Map<String, dynamic> json) {
    return XrayAnalysis(
      id: json['id'] as int,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String?,
      assignedDoctorId: json['assignedDoctorId'] as String?,
      assignedDoctorName: json['assignedDoctorName'] as String?,
      originalFileName: json['originalFileName'] as String,
      contentType: json['contentType'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int?,
      status: analysisStatusFromJson(json['status'] as String?),
      aiPrimaryDiagnosis: diseaseTypeFromJson(json['aiPrimaryDiagnosis'] as String?),
      aiPrimaryDiagnosisDisplayName: json['aiPrimaryDiagnosisDisplayName'] as String?,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble(),
      aiFindings: json['aiFindings'] as String?,
      aiDetectedAbnormalities: json['aiDetectedAbnormalities'] as String?,
      aiAllPredictionsJson: json['aiAllPredictionsJson'] as String?,  // ← NEW
      validatedByDoctorId: json['validatedByDoctorId'] as String?,
      validatedByDoctorName: json['validatedByDoctorName'] as String?,
      doctorDiagnosis: diseaseTypeFromJson(json['doctorDiagnosis'] as String?),
      doctorDiagnosisDisplayName: json['doctorDiagnosisDisplayName'] as String?,
      doctorNotes: json['doctorNotes'] as String?,
      validatedAt: json['validatedAt'] as String?,
      patientNotes: json['patientNotes'] as String?,
      uploadedAt: json['uploadedAt'] as String,
      analyzedAt: json['analyzedAt'] as String?,
    );
  }
}