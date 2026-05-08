// lib/features/profile/presentation/pages/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../core/models/patient_profile.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EditProfilePage
//
// Reached via: context.push('/profile/edit') from ProfilePage.
// Pre-fills all fields from the cached patientProfileProvider.
// On save: calls ProfileRemoteDatasource.updatePatientProfile()
//          then invalidates patientProfileProvider so ProfilePage reloads.
// ─────────────────────────────────────────────────────────────────────────────
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _saveError;

  // Controllers — pre-filled in initState from cached provider value
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _middleName;
  late final TextEditingController _phone;
  late final TextEditingController _dateOfBirth;
  late final TextEditingController _gender;
  late final TextEditingController _bloodType;
  late final TextEditingController _heightCm;
  late final TextEditingController _weightKg;
  late final TextEditingController _allergies;
  late final TextEditingController _chronicDiseases;
  late final TextEditingController _emergencyName;
  late final TextEditingController _emergencyPhone;
  late final TextEditingController _address;
  late final TextEditingController _insuranceNumber;
  late final TextEditingController _occupation;

  @override
  void initState() {
    super.initState();
    // Read the already-loaded profile from cache (no extra network call)
    final profile = ref.read(patientProfileProvider).valueOrNull;
    _firstName = TextEditingController(text: profile?.firstName ?? '');
    _lastName = TextEditingController(text: profile?.lastName ?? '');
    _middleName = TextEditingController(text: profile?.middleName ?? '');
    _phone = TextEditingController(text: profile?.phoneNumber ?? '');
    _dateOfBirth = TextEditingController(text: profile?.dateOfBirth ?? '');
    _gender = TextEditingController(text: profile?.gender ?? '');
    _bloodType = TextEditingController(text: profile?.bloodType ?? '');
    _heightCm = TextEditingController(
        text: profile?.heightCm?.toStringAsFixed(0) ?? '');
    _weightKg = TextEditingController(
        text: profile?.weightKg?.toStringAsFixed(1) ?? '');
    _allergies = TextEditingController(text: profile?.allergies ?? '');
    _chronicDiseases =
        TextEditingController(text: profile?.chronicDiseases ?? '');
    _emergencyName =
        TextEditingController(text: profile?.emergencyContactName ?? '');
    _emergencyPhone =
        TextEditingController(text: profile?.emergencyContactPhone ?? '');
    _address = TextEditingController(text: profile?.address ?? '');
    _insuranceNumber =
        TextEditingController(text: profile?.insuranceNumber ?? '');
    _occupation = TextEditingController(text: profile?.occupation ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _firstName, _lastName, _middleName, _phone, _dateOfBirth,
      _gender, _bloodType, _heightCm, _weightKg, _allergies,
      _chronicDiseases, _emergencyName, _emergencyPhone, _address,
      _insuranceNumber, _occupation,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _saveError = null; });

    try {
      // Build the request map — only send non-empty values
      final body = <String, dynamic>{
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        if (_middleName.text.trim().isNotEmpty)
          'middleName': _middleName.text.trim(),
        if (_phone.text.trim().isNotEmpty) 'phoneNumber': _phone.text.trim(),
        if (_dateOfBirth.text.trim().isNotEmpty)
          'dateOfBirth': _dateOfBirth.text.trim(),
        if (_gender.text.trim().isNotEmpty) 'gender': _gender.text.trim(),
        if (_bloodType.text.trim().isNotEmpty)
          'bloodType': _bloodType.text.trim(),
        if (_heightCm.text.trim().isNotEmpty)
          'heightCm': double.tryParse(_heightCm.text.trim()),
        if (_weightKg.text.trim().isNotEmpty)
          'weightKg': double.tryParse(_weightKg.text.trim()),
        if (_allergies.text.trim().isNotEmpty)
          'allergies': _allergies.text.trim(),
        if (_chronicDiseases.text.trim().isNotEmpty)
          'chronicDiseases': _chronicDiseases.text.trim(),
        if (_emergencyName.text.trim().isNotEmpty)
          'emergencyContactName': _emergencyName.text.trim(),
        if (_emergencyPhone.text.trim().isNotEmpty)
          'emergencyContactPhone': _emergencyPhone.text.trim(),
        if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
        if (_insuranceNumber.text.trim().isNotEmpty)
          'insuranceNumber': _insuranceNumber.text.trim(),
        if (_occupation.text.trim().isNotEmpty)
          'occupation': _occupation.text.trim(),
      };

      await ref.read(profileDatasourceProvider).updatePatientProfile(body);

      // Reload profile page with fresh data
      ref.invalidate(patientProfileProvider);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saveError = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Error banner ─────────────────────────────────────────────
              if (_saveError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFC62828), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_saveError!,
                            style: const TextStyle(
                                color: Color(0xFFC62828), fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Personal Information ─────────────────────────────────────
              _sectionHeader('Personal Information'),
              _field('First Name', _firstName,
                  validator: _required, capitalization: TextCapitalization.words),
              _field('Last Name', _lastName,
                  validator: _required, capitalization: TextCapitalization.words),
              _field('Middle Name', _middleName,
                  capitalization: TextCapitalization.words),
              _field('Phone Number', _phone,
                  keyboard: TextInputType.phone),
              _field('Date of Birth', _dateOfBirth,
                  hint: 'YYYY-MM-DD',
                  keyboard: TextInputType.datetime),
              _field('Occupation', _occupation,
                  capitalization: TextCapitalization.words),
              _field('Address', _address,
                  capitalization: TextCapitalization.sentences),

              // ── Medical Information ──────────────────────────────────────
              _sectionHeader('Medical Information'),
              _field('Gender', _gender,
                  hint: 'MALE / FEMALE / OTHER'),
              _field('Blood Type', _bloodType,
                  hint: 'A_POSITIVE / B_NEGATIVE / etc.'),
              _field('Height (cm)', _heightCm,
                  keyboard: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly]),
              _field('Weight (kg)', _weightKg,
                  keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field('Allergies', _allergies, maxLines: 2,
                  capitalization: TextCapitalization.sentences),
              _field('Chronic Diseases', _chronicDiseases, maxLines: 2,
                  capitalization: TextCapitalization.sentences),

              // ── Emergency Contact ────────────────────────────────────────
              _sectionHeader('Emergency Contact'),
              _field('Contact Name', _emergencyName,
                  capitalization: TextCapitalization.words),
              _field('Contact Phone', _emergencyPhone,
                  keyboard: TextInputType.phone),

              // ── Insurance ────────────────────────────────────────────────
              _sectionHeader('Insurance'),
              _field('Insurance Number', _insuranceNumber),

              const SizedBox(height: 32),

              // ── Save button ──────────────────────────────────────────────
              AppButton(
                label: 'Save Changes',
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A73E8),
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboard,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? formatters,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        textCapitalization: capitalization,
        inputFormatters: formatters,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          labelStyle:
              TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}