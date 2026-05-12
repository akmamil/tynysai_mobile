import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/models/patient_profile.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider); // следим за языком
    final locale = ref.read(localeProvider);
    S.setLocale(AppLocale.values.firstWhere(
          (e) => e.name == locale.languageCode,
      orElse: () => AppLocale.ru,
    ));

    final state = ref.watch(patientProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(S.myProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: S.editProfile,
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(patientProfileProvider),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(patientProfileProvider),
        ),
        data: (profile) => _ProfileBody(profile: profile),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});
  final PatientProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                Text(profile.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(profile.email, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          _Section(title: S.personalInfo, children: [
            _Field(S.firstName, profile.firstName),
            _Field(S.lastName, profile.lastName),
            if (profile.middleName != null) _Field(S.middleName, profile.middleName!),
            _Field(S.phone, profile.phoneNumber ?? '—'),
            _Field(S.dateOfBirth, profile.dateOfBirth ?? '—'),
            _Field('Age', profile.age?.toString() ?? '—'),
            _Field(S.gender, profile.gender ?? '—'),
            _Field(S.occupation, profile.occupation ?? '—'),
            _Field(S.address, profile.address ?? '—'),
          ]),
          const SizedBox(height: 18),

          _Section(title: S.medicalInfo, children: [
            _Field(S.bloodType, profile.bloodType ?? '—'),
            _Field(S.height, profile.heightCm != null ? '${profile.heightCm!.toStringAsFixed(0)} cm' : '—'),
            _Field(S.weight, profile.weightKg != null ? '${profile.weightKg!.toStringAsFixed(1)} kg' : '—'),
            _Field(S.allergies, profile.allergies ?? '—'),
            _Field(S.chronicDiseases, profile.chronicDiseases ?? '—'),
            _BoolField('Smoker', profile.smoker),
            _BoolField('Alcohol Use', profile.alcoholUser),
          ]),
          const SizedBox(height: 18),

          _Section(title: S.emergencyContact, children: [
            _Field(S.contactName, profile.emergencyContactName ?? '—'),
            _Field(S.contactPhone, profile.emergencyContactPhone ?? '—'),
          ]),
          const SizedBox(height: 18),

          _Section(title: S.insurance, children: [
            _Field(S.insuranceNumber, profile.insuranceNumber ?? '—'),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5)),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}

class _BoolField extends StatelessWidget {
  const _BoolField(this.label, this.value);
  final String label;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return _Field(label, value == null ? '—' : (value! ? 'Yes' : 'No'));
  }
}