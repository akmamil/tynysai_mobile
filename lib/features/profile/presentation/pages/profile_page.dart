// lib/features/profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/patient_profile.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(patientProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ── ADDED: edit button navigates to edit page ──────────────────
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

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});
  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + name header ─────────────────────────────────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF1A73E8),
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
                const SizedBox(height: 12),
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Personal info ────────────────────────────────────────────────
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
          const SizedBox(height: 16),

          // ── Medical info ─────────────────────────────────────────────────
          _Section(
            title: 'Medical Information',
            children: [
              _Field('Blood Type', profile.bloodType ?? '—'),
              _Field(
                  'Height',
                  profile.heightCm != null
                      ? '${profile.heightCm!.toStringAsFixed(0)} cm'
                      : '—'),
              _Field(
                  'Weight',
                  profile.weightKg != null
                      ? '${profile.weightKg!.toStringAsFixed(1)} kg'
                      : '—'),
              _Field('Allergies', profile.allergies ?? '—'),
              _Field('Chronic Diseases', profile.chronicDiseases ?? '—'),
              _Field('Medical History', profile.medicalHistory ?? '—'),
              _BoolField('Smoker', profile.smoker),
              _BoolField('Alcohol Use', profile.alcoholUser),
            ],
          ),
          const SizedBox(height: 16),

          // ── Emergency contact ────────────────────────────────────────────
          _Section(
            title: 'Emergency Contact',
            children: [
              _Field('Name', profile.emergencyContactName ?? '—'),
              _Field('Phone', profile.emergencyContactPhone ?? '—'),
            ],
          ),
          const SizedBox(height: 16),

          // ── Insurance ────────────────────────────────────────────────────
          _Section(
            title: 'Insurance',
            children: [
              _Field('Insurance Number', profile.insuranceNumber ?? '—'),
            ],
          ),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A73E8),
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
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E))),
          ),
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