// lib/features/profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/patient_profile.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(patientProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(patientProfileProvider),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(patientProfileProvider),
        ),
        data: (profile) => _ProfileBody(profile: profile),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
  });

  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
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
                    profile.fullName.isNotEmpty
                        ? profile.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  profile.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _Section(
            title: 'Personal Information',
            children: [
              _Field('First Name', profile.firstName),
              _Field('Last Name', profile.lastName),

              if (profile.middleName != null)
                _Field('Middle Name', profile.middleName!),

              _Field('Phone', profile.phoneNumber ?? '—'),
              _Field('Date of Birth', profile.dateOfBirth ?? '—'),
              _Field('Age', profile.age?.toString() ?? '—'),
              _Field('Gender', profile.gender ?? '—'),
              _Field('Occupation', profile.occupation ?? '—'),
              _Field('Address', profile.address ?? '—'),
            ],
          ),

          const SizedBox(height: 18),

          _Section(
            title: 'Medical Information',
            children: [
              _Field('Blood Type', profile.bloodType ?? '—'),

              _Field(
                'Height',
                profile.heightCm != null
                    ? '${profile.heightCm!.toStringAsFixed(0)} cm'
                    : '—',
              ),

              _Field(
                'Weight',
                profile.weightKg != null
                    ? '${profile.weightKg!.toStringAsFixed(1)} kg'
                    : '—',
              ),

              _Field('Allergies', profile.allergies ?? '—'),

              _Field(
                'Chronic Diseases',
                profile.chronicDiseases ?? '—',
              ),

              _Field(
                'Medical History',
                profile.medicalHistory ?? '—',
              ),

              _BoolField('Smoker', profile.smoker),
              _BoolField('Alcohol Use', profile.alcoholUser),
            ],
          ),

          const SizedBox(height: 18),

          _Section(
            title: 'Emergency Contact',
            children: [
              _Field(
                'Name',
                profile.emergencyContactName ?? '—',
              ),

              _Field(
                'Phone',
                profile.emergencyContactPhone ?? '—',
              ),
            ],
          ),

          const SizedBox(height: 18),

          _Section(
            title: 'Insurance',
            children: [
              _Field(
                'Insurance Number',
                profile.insuranceNumber ?? '—',
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              10,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const Divider(height: 1),

          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(
    this.label,
    this.value,
  );

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 11,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoolField extends StatelessWidget {
  const _BoolField(
    this.label,
    this.value,
  );

  final String label;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return _Field(
      label,
      value == null ? '—' : (value! ? 'Yes' : 'No'),
    );
  }
}