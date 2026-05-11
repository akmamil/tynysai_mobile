// lib/core/models/appointment.dart

// ─────────────────────────────────────────────────────────────────────────────
// AppointmentStatus enum
// ─────────────────────────────────────────────────────────────────────────────

enum AppointmentStatus {
  scheduled,
  completed,
  cancelled,
  noShow,
}

extension AppointmentStatusX on AppointmentStatus {
  String get displayName => switch (this) {
        AppointmentStatus.scheduled => 'Scheduled',
        AppointmentStatus.completed => 'Completed',
        AppointmentStatus.cancelled => 'Cancelled',
        AppointmentStatus.noShow => 'No Show',
      };

  /// Whether this appointment is still in the future / actionable.
  bool get isUpcoming => this == AppointmentStatus.scheduled;

  /// Whether the appointment has a terminal (non-editable) status.
  bool get isTerminal =>
      this == AppointmentStatus.completed ||
      this == AppointmentStatus.cancelled ||
      this == AppointmentStatus.noShow;
}

/// Converts a backend enum string (e.g. "SCHEDULED") to [AppointmentStatus].
AppointmentStatus appointmentStatusFromJson(String? s) => switch (s) {
      'SCHEDULED' => AppointmentStatus.scheduled,
      'COMPLETED' => AppointmentStatus.completed,
      'CANCELLED' => AppointmentStatus.cancelled,
      'NO_SHOW' => AppointmentStatus.noShow,
      _ => AppointmentStatus.scheduled,
    };

// ─────────────────────────────────────────────────────────────────────────────
// Appointment model
// ─────────────────────────────────────────────────────────────────────────────

class Appointment {
  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    this.doctorSpecialization,
    required this.appointmentDate,
    this.startTime,
    this.endTime,
    required this.status,
    this.reason,
    this.notes,
    this.meetingLink,
    required this.createdAt,
    this.updatedAt,
  });

  final int id;

  /// UUID of the patient (matches JWT sub).
  final String patientId;

  /// UUID of the assigned doctor.
  final String doctorId;

  /// Doctor's full name — de-normalised for display without an extra request.
  final String doctorName;

  final String? doctorSpecialization;

  /// ISO-8601 date string, e.g. "2024-03-15" or "2024-03-15T09:00:00Z".
  final String appointmentDate;

  /// "09:00" — optional time component (may be absent in v1).
  final String? startTime;
  final String? endTime;

  final AppointmentStatus status;

  /// Patient-supplied reason for the visit.
  final String? reason;

  /// Doctor / admin notes added after the visit.
  final String? notes;

  /// Telehealth link, if applicable.
  final String? meetingLink;

  final String createdAt;
  final String? updatedAt;

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// True when the appointment date is today or in the future and status is
  /// scheduled — used to split upcoming vs. past sections in the list.
  bool get isUpcoming {
    if (!status.isUpcoming) return false;
    try {
      final date = DateTime.parse(appointmentDate);
      final now = DateTime.now();
      // Compare date only (ignore time-of-day).
      final today = DateTime(now.year, now.month, now.day);
      final apptDay = DateTime(date.year, date.month, date.day);
      return !apptDay.isBefore(today);
    } catch (_) {
      return false;
    }
  }

  // ── JSON ─────────────────────────────────────────────────────────────────

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int,
      patientId: json['patientId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? 'Unknown Doctor',
      doctorSpecialization: json['doctorSpecialization'] as String?,
      appointmentDate: json['appointmentDate'] as String? ??
          json['scheduledAt'] as String? ??
          '',
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      status: appointmentStatusFromJson(json['status'] as String?),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      meetingLink: json['meetingLink'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorSpecialization': doctorSpecialization,
        'appointmentDate': appointmentDate,
        'startTime': startTime,
        'endTime': endTime,
        'status': status.name.toUpperCase(),
        'reason': reason,
        'notes': notes,
        'meetingLink': meetingLink,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  /// Returns a copy of this appointment with [status] replaced.
  /// Used optimistically after a successful cancel request.
  Appointment copyWith({AppointmentStatus? status, String? updatedAt}) {
    return Appointment(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialization: doctorSpecialization,
      appointmentDate: appointmentDate,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      reason: reason,
      notes: notes,
      meetingLink: meetingLink,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
