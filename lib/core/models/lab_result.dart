// lib/core/models/lab_result.dart
//
// Maps to LabResultResponse from the backend (medical-record-service).
// Mirrors the structure of DiagnosticReport — same pagination/wrapping pattern.

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum LabResultStatus { pending, completed, cancelled }

enum LabTestType {
  completeBloodCount,
  basicMetabolicPanel,
  lipidPanel,
  liverFunction,
  thyroidFunction,
  urinalysis,
  other,
}

/// Status of a single measured test item within a lab result.
enum LabItemStatus { normal, low, high, criticalLow, criticalHigh }

// ─────────────────────────────────────────────────────────────────────────────
// JSON deserializers (match backend enum string values exactly)
// ─────────────────────────────────────────────────────────────────────────────

LabResultStatus labResultStatusFromJson(String? s) => switch (s) {
      'PENDING' => LabResultStatus.pending,
      'COMPLETED' => LabResultStatus.completed,
      'CANCELLED' => LabResultStatus.cancelled,
      _ => LabResultStatus.pending,
    };

LabTestType labTestTypeFromJson(String? s) => switch (s) {
      'COMPLETE_BLOOD_COUNT' => LabTestType.completeBloodCount,
      'BASIC_METABOLIC_PANEL' => LabTestType.basicMetabolicPanel,
      'LIPID_PANEL' => LabTestType.lipidPanel,
      'LIVER_FUNCTION' => LabTestType.liverFunction,
      'THYROID_FUNCTION' => LabTestType.thyroidFunction,
      'URINALYSIS' => LabTestType.urinalysis,
      _ => LabTestType.other,
    };

LabItemStatus labItemStatusFromJson(String? s) => switch (s) {
      'NORMAL' => LabItemStatus.normal,
      'LOW' => LabItemStatus.low,
      'HIGH' => LabItemStatus.high,
      'CRITICAL_LOW' => LabItemStatus.criticalLow,
      'CRITICAL_HIGH' => LabItemStatus.criticalHigh,
      _ => LabItemStatus.normal,
    };

// ─────────────────────────────────────────────────────────────────────────────
// Extensions — display helpers used by the UI layer
// ─────────────────────────────────────────────────────────────────────────────

extension LabResultStatusX on LabResultStatus {
  String get displayName => switch (this) {
        LabResultStatus.pending => 'Pending',
        LabResultStatus.completed => 'Completed',
        LabResultStatus.cancelled => 'Cancelled',
      };

  bool get isCompleted => this == LabResultStatus.completed;
}

extension LabTestTypeX on LabTestType {
  String get displayName => switch (this) {
        LabTestType.completeBloodCount => 'Complete Blood Count',
        LabTestType.basicMetabolicPanel => 'Basic Metabolic Panel',
        LabTestType.lipidPanel => 'Lipid Panel',
        LabTestType.liverFunction => 'Liver Function',
        LabTestType.thyroidFunction => 'Thyroid Function',
        LabTestType.urinalysis => 'Urinalysis',
        LabTestType.other => 'Lab Test',
      };

  String get shortName => switch (this) {
        LabTestType.completeBloodCount => 'CBC',
        LabTestType.basicMetabolicPanel => 'BMP',
        LabTestType.lipidPanel => 'Lipid Panel',
        LabTestType.liverFunction => 'LFT',
        LabTestType.thyroidFunction => 'TFT',
        LabTestType.urinalysis => 'UA',
        LabTestType.other => 'Test',
      };
}

extension LabItemStatusX on LabItemStatus {
  bool get isNormal => this == LabItemStatus.normal;
  bool get isCritical =>
      this == LabItemStatus.criticalLow || this == LabItemStatus.criticalHigh;
  bool get isAbnormal => !isNormal;

  String get displayName => switch (this) {
        LabItemStatus.normal => 'Normal',
        LabItemStatus.low => 'Low',
        LabItemStatus.high => 'High',
        LabItemStatus.criticalLow => 'Critical Low',
        LabItemStatus.criticalHigh => 'Critical High',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// LabResultItem — a single measured parameter inside a LabResult
// ─────────────────────────────────────────────────────────────────────────────

class LabResultItem {
  const LabResultItem({
    this.id,
    required this.name,
    required this.value,
    this.unit,
    this.referenceRange,
    required this.status,
  });

  final int? id;

  /// Human-readable test parameter name, e.g. "White Blood Cells".
  final String name;

  /// Measured value as a string to preserve formatting, e.g. "11.2".
  final String value;

  /// Unit of measurement, e.g. "K/µL", "mg/dL". Null when dimensionless.
  final String? unit;

  /// Reference range as a display string, e.g. "4.5–11.0", ">40", "<200".
  final String? referenceRange;

  final LabItemStatus status;

  factory LabResultItem.fromJson(Map<String, dynamic> json) {
    return LabResultItem(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      unit: json['unit'] as String?,
      referenceRange: json['referenceRange'] as String?,
      status: labItemStatusFromJson(json['status'] as String?),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LabResult — the top-level lab result record
// ─────────────────────────────────────────────────────────────────────────────

class LabResult {
  const LabResult({
    required this.id,
    this.labNumber,
    required this.patientId,
    this.patientName,
    this.doctorId,
    this.doctorName,
    this.doctorSpecialization,
    required this.testName,
    required this.testType,
    this.testTypeDisplayName,
    required this.status,
    required this.orderedAt,
    this.resultDate,
    this.notes,
    required this.items,
  });

  final int id;
  final String? labNumber;
  final String patientId;
  final String? patientName;
  final String? doctorId;
  final String? doctorName;
  final String? doctorSpecialization;

  /// Overridable display name for the test (backend may localise it).
  final String testName;
  final LabTestType testType;
  final String? testTypeDisplayName;
  final LabResultStatus status;

  /// ISO-8601 string — when the test was ordered.
  final String orderedAt;

  /// ISO-8601 string — when results were finalised. Null when still pending.
  final String? resultDate;

  /// Optional doctor's comment on the overall result set.
  final String? notes;

  /// Ordered list of individual measured parameters.
  final List<LabResultItem> items;

  // ── Derived helpers ──────────────────────────────────────────────────────

  /// True when any item is flagged abnormal (High / Low / Critical).
  bool get hasAbnormalItems => items.any((i) => i.status.isAbnormal);

  /// True when any item is critical.
  bool get hasCriticalItems => items.any((i) => i.status.isCritical);

  /// Number of abnormal items — shown in the list card.
  int get abnormalCount => items.where((i) => i.status.isAbnormal).length;

  factory LabResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .map((e) => LabResultItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <LabResultItem>[];

    return LabResult(
      id: json['id'] as int,
      labNumber: json['labNumber'] as String?,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String?,
      doctorId: json['doctorId'] as String?,
      doctorName: json['doctorName'] as String?,
      doctorSpecialization: json['doctorSpecialization'] as String?,
      testName: json['testName'] as String? ?? '',
      testType: labTestTypeFromJson(json['testType'] as String?),
      testTypeDisplayName: json['testTypeDisplayName'] as String?,
      status: labResultStatusFromJson(json['status'] as String?),
      orderedAt: json['orderedAt'] as String,
      resultDate: json['resultDate'] as String?,
      notes: json['notes'] as String?,
      items: items,
    );
  }
}