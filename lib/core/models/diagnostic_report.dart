// lib/core/models/diagnostic_report.dart
//
// Maps exactly to DiagnosticReportResponse from the backend
// (medical-record-service).
// Source of truth: web frontend /src/types/index.ts DiagnosticReportResponse

import 'enums.dart';

class DiagnosticReport {
  const DiagnosticReport({
    required this.id,
    this.reportNumber,
    required this.patientId,
    this.patientName,
    this.doctorId,
    this.doctorName,
    this.doctorSpecialization,
    this.xrayAnalysisId,
    this.labResultId,
    required this.finalDiagnosis,
    this.finalDiagnosisDisplayName,
    required this.severity,
    this.severityDisplayName,
    required this.clinicalFindings,
    this.treatmentRecommendations,
    this.medicationRecommendations,
    this.lifestyleRecommendations,
    this.followUpDate,
    required this.reportText,
    required this.sentToPatient,
    this.sentAt,
    required this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String? reportNumber;
  final String patientId;
  final String? patientName;
  final String? doctorId;
  final String? doctorName;
  final String? doctorSpecialization;
  final int? xrayAnalysisId;
  final int? labResultId;
  final DiseaseType finalDiagnosis;
  final String? finalDiagnosisDisplayName;
  final Severity severity;
  final String? severityDisplayName;
  final String clinicalFindings;
  final String? treatmentRecommendations;
  final String? medicationRecommendations;
  final String? lifestyleRecommendations;
  final String? followUpDate;
  final String reportText;
  final bool sentToPatient;
  final String? sentAt;
  final String createdAt;
  final String? updatedAt;

  factory DiagnosticReport.fromJson(Map<String, dynamic> json) {
    return DiagnosticReport(
      id: json['id'] as int,
      reportNumber: json['reportNumber'] as String?,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String?,
      doctorId: json['doctorId'] as String?,
      doctorName: json['doctorName'] as String?,
      doctorSpecialization: json['doctorSpecialization'] as String?,
      xrayAnalysisId: json['xrayAnalysisId'] as int?,
      labResultId: json['labResultId'] as int?,
      finalDiagnosis:
          diseaseTypeFromJson(json['finalDiagnosis'] as String?) ??
              DiseaseType.other,
      finalDiagnosisDisplayName:
          json['finalDiagnosisDisplayName'] as String?,
      severity: severityFromJson(json['severity'] as String?),
      severityDisplayName: json['severityDisplayName'] as String?,
      clinicalFindings: json['clinicalFindings'] as String? ?? '',
      treatmentRecommendations:
          json['treatmentRecommendations'] as String?,
      medicationRecommendations:
          json['medicationRecommendations'] as String?,
      lifestyleRecommendations:
          json['lifestyleRecommendations'] as String?,
      followUpDate: json['followUpDate'] as String?,
      reportText: json['reportText'] as String? ?? '',
      sentToPatient: json['sentToPatient'] as bool? ?? false,
      sentAt: json['sentAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

/// Add this to enums.dart — Severity enum
/// (already exists as a Dart enum but needs the fromJson function)
Severity severityFromJson(String? s) => switch (s) {
      'NONE' => Severity.none,
      'MILD' => Severity.mild,
      'MODERATE' => Severity.moderate,
      'SEVERE' => Severity.severe,
      'CRITICAL' => Severity.critical,
      _ => Severity.none,
    };