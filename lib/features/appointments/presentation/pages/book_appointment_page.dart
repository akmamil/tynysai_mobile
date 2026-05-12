// lib/features/appointments/presentation/pages/book_appointment_page.dart
//
// Three-step booking flow contained in a single ConsumerStatefulWidget:
//
//   Step 0 — Doctor selection  (fetches GET /api/doctors/approved)
//   Step 1 — Date + time slot  (client-generated 30-min slots, no availability API)
//   Step 2 — Review & confirm  (reason field + submit → POST /api/appointments)
//
// Navigation inside the page is managed by local _step int state.
// The AppBar back arrow pops to the previous step (or closes the page on step 0).
// State management follows the XrayUploadNotifier sealed-state pattern.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/doctor_profile.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/book_appointment_provider.dart';
import '../../data/appointments_remote_datasource.dart';
import '../../data/doctors_remote_datasource.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BookAppointmentPage
// ─────────────────────────────────────────────────────────────────────────────

class BookAppointmentPage extends ConsumerStatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  ConsumerState<BookAppointmentPage> createState() =>
      _BookAppointmentPageState();
}

class _BookAppointmentPageState extends ConsumerState<BookAppointmentPage> {
  // ── Step tracking ─────────────────────────────────────────────────────────
  int _step = 0;

  // ── Selections ────────────────────────────────────────────────────────────
  DoctorProfile? _selectedDoctor;
  DateTime? _selectedDate;
  _TimeSlot? _selectedSlot;
  final _reasonController = TextEditingController();

  // ── Date carousel — today + 13 days (2 weeks) ─────────────────────────────
  late final List<DateTime> _dateOptions = List.generate(14, (i) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: i));
  });

  // ── Time slots — 30-min, 09:00–17:00, skip 13:00 lunch ───────────────────
  static final List<_TimeSlot> _slots = _generateSlots();

  static List<_TimeSlot> _generateSlots() {
    final slots = <_TimeSlot>[];
    for (var h = 9; h < 17; h++) {
      // Skip 13:00 (lunch break)
      if (h == 13) continue;
      for (final m in [0, 30]) {
        final start = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        final endH = m == 30 ? h + 1 : h;
        final endM = m == 30 ? 0 : 30;
        final end = '${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';
        slots.add(_TimeSlot(start: start, end: end));
      }
    }
    return slots;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _nextStep() => setState(() => _step++);

  void _prevStep() {
    if (_step == 0) {
      context.pop();
    } else {
      setState(() => _step--);
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final doctor = _selectedDoctor;
    final date = _selectedDate;
    final slot = _selectedSlot;
    if (doctor == null || date == null || slot == null) return;

    // Формируем полный datetime: '2026-05-14T16:30:00'
    final dateTimeStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T${slot.start}:00';

    final request = BookAppointmentRequest(
      doctorId: doctor.userId,
      appointmentDateTime: dateTimeStr,
      patientComplaints: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
    );

    await ref.read(bookAppointmentProvider.notifier).book(request);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Listen for terminal states — navigate or show error.
    ref.listen<BookingState>(bookAppointmentProvider, (_, next) {
      if (next is BookingSuccess) {
        ref.read(bookAppointmentProvider.notifier).reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Appointment booked successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
        // Go back to the appointments list. It was already invalidated by
        // the notifier so it will show the new appointment immediately.
        context.go('/appointments');
      }
    });

    final stepTitles = ['Choose Doctor', 'Date & Time', 'Confirm'];

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _prevStep();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(stepTitles[_step]),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: _prevStep,
          ),
        ),
        body: Column(
          children: [
            // ── Step progress bar ─────────────────────────────────────────
            _StepProgressBar(currentStep: _step, totalSteps: 3),

            // ── Step body ─────────────────────────────────────────────────
            Expanded(
              child: switch (_step) {
                0 => _DoctorStep(
                    selectedDoctor: _selectedDoctor,
                    onSelect: (doctor) {
                      setState(() => _selectedDoctor = doctor);
                      _nextStep();
                    },
                  ),
                1 => _DateTimeStep(
                    dateOptions: _dateOptions,
                    slots: _slots,
                    selectedDate: _selectedDate,
                    selectedSlot: _selectedSlot,
                    onDateSelected: (d) => setState(() {
                      _selectedDate = d;
                      _selectedSlot = null; // reset slot on date change
                    }),
                    onSlotSelected: (s) => setState(() => _selectedSlot = s),
                    onNext: _selectedDate != null && _selectedSlot != null
                        ? _nextStep
                        : null,
                  ),
                _ => _ConfirmStep(
                    doctor: _selectedDoctor!,
                    date: _selectedDate!,
                    slot: _selectedSlot!,
                    reasonController: _reasonController,
                    onSubmit: _submit,
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StepProgressBar
// ─────────────────────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(totalSteps, (i) {
              final isActive = i <= currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: isActive ? AppGradients.brand : null,
                          color: isActive ? null : AppColors.border,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: AppText.labelSm,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 0 — Doctor selection
// ─────────────────────────────────────────────────────────────────────────────

class _DoctorStep extends ConsumerWidget {
  const _DoctorStep({
    required this.selectedDoctor,
    required this.onSelect,
  });

  final DoctorProfile? selectedDoctor;
  final ValueChanged<DoctorProfile> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(approvedDoctorsProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(approvedDoctorsProvider),
      ),
      data: (doctors) {
        if (doctors.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_search_outlined,
                        size: 36, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  const Text('No doctors available',
                      style: AppText.h3, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('There are no approved doctors at this time.',
                      style: AppText.bodySm, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: doctors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _DoctorCard(
            doctor: doctors[i],
            isSelected: selectedDoctor?.id == doctors[i].id,
            onTap: () => onSelect(doctors[i]),
          ),
        );
      },
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.isSelected,
    required this.onTap,
  });

  final DoctorProfile doctor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : const Color(0x0A000000),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  doctor.firstName.isNotEmpty
                      ? doctor.firstName[0].toUpperCase()
                      : 'D',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor.fullName}',
                    style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (doctor.specialization != null)
                    Text(doctor.specialization!, style: AppText.bodySm),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (doctor.hospitalName != null)
                        _InfoChip(
                          icon: Icons.local_hospital_outlined,
                          label: doctor.hospitalName!,
                        ),
                      if (doctor.yearsOfExperience != null)
                        _InfoChip(
                          icon: Icons.workspace_premium_outlined,
                          label: '${doctor.yearsOfExperience} yrs exp.',
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Check indicator
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  gradient: AppGradients.brand,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(label, style: AppText.labelSm.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Date + time slot
// ─────────────────────────────────────────────────────────────────────────────

class _DateTimeStep extends StatelessWidget {
  const _DateTimeStep({
    required this.dateOptions,
    required this.slots,
    required this.selectedDate,
    required this.selectedSlot,
    required this.onDateSelected,
    required this.onSlotSelected,
    required this.onNext,
  });

  final List<DateTime> dateOptions;
  final List<_TimeSlot> slots;
  final DateTime? selectedDate;
  final _TimeSlot? selectedSlot;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<_TimeSlot> onSlotSelected;
  final VoidCallback? onNext;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Date carousel ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Select a date', style: AppText.h3),
        ),
        SizedBox(
          height: 82,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: dateOptions.length,
            itemBuilder: (_, i) {
              final date = dateOptions[i];
              final isSelected = selectedDate?.day == date.day &&
                  selectedDate?.month == date.month;
              final isToday = i == 0;
              // 1 = Mon … 7 = Sun
              final weekday = _weekdays[date.weekday - 1];

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppGradients.brand : null,
                    color: isSelected ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.border,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday ? 'Today' : weekday,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _months[date.month],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ── Time slots ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            selectedDate != null ? 'Select a time slot' : 'Pick a date first',
            style: AppText.h3,
          ),
        ),
        Expanded(
          child: selectedDate == null
              ? Center(
                  child: Text(
                    'Choose a date above to see available slots',
                    style: AppText.bodySm,
                    textAlign: TextAlign.center,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (_, i) {
                    final slot = slots[i];
                    final isSelected = selectedSlot?.start == slot.start;
                    return GestureDetector(
                      onTap: () => onSlotSelected(slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppGradients.brand : null,
                          color: isSelected ? null : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          slot.start,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // ── Continue button ───────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GradientButton(
              label: 'Continue',
              icon: Icons.arrow_forward_outlined,
              onPressed: onNext,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Review & Confirm
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmStep extends ConsumerWidget {
  const _ConfirmStep({
    required this.doctor,
    required this.date,
    required this.slot,
    required this.reasonController,
    required this.onSubmit,
  });

  final DoctorProfile doctor;
  final DateTime date;
  final _TimeSlot slot;
  final TextEditingController reasonController;
  final VoidCallback onSubmit;

  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookAppointmentProvider);
    final isLoading = bookingState is BookingLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary hero card ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: AppDecorations.gradientCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appointment Summary', style: AppText.onDarkMuted),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          doctor.firstName.isNotEmpty
                              ? doctor.firstName[0].toUpperCase()
                              : 'D',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${doctor.fullName}',
                            style: AppText.onDarkBold.copyWith(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (doctor.specialization != null)
                            Text(doctor.specialization!,
                                style: AppText.onDarkMuted),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${_months[date.month]} ${date.day}, ${date.year}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time_outlined,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${slot.start} – ${slot.end}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Reason field ───────────────────────────────────────────────
          SectionLabel('Reason for visit (optional)'),
          TextField(
            controller: reasonController,
            enabled: !isLoading,
            maxLines: 4,
            maxLength: 500,
            style: AppText.bodyMd,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText:
                  'Describe your symptoms, duration, or any relevant history...',
              hintStyle: AppText.bodyMd.copyWith(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              counterStyle: AppText.bodyXs,
            ),
          ),
          const SizedBox(height: 16),

          // ── Inline error from booking attempt ──────────────────────────
          if (bookingState is BookingError) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.failedBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.30)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bookingState.message,
                      style: AppText.bodySm
                          .copyWith(color: AppColors.failedText),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Disclaimer ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Booking is subject to doctor availability. '
                    'You may receive a confirmation or rescheduling request.',
                    style:
                        AppText.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Submit ─────────────────────────────────────────────────────
          GradientButton(
            label: isLoading ? 'Booking...' : 'Confirm Booking',
            icon: isLoading ? null : Icons.check_circle_outline,
            isLoading: isLoading,
            onPressed: isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TimeSlot — simple value object
// ─────────────────────────────────────────────────────────────────────────────

class _TimeSlot {
  const _TimeSlot({required this.start, required this.end});
  final String start; // 'HH:mm'
  final String end;   // 'HH:mm'
}
