import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/profile_provider.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/l10n/app_strings.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _saveError;

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
    final profile = ref.read(patientProfileProvider).valueOrNull;
    _firstName = TextEditingController(text: profile?.firstName ?? '');
    _lastName = TextEditingController(text: profile?.lastName ?? '');
    _middleName = TextEditingController(text: profile?.middleName ?? '');
    _phone = TextEditingController(text: profile?.phoneNumber ?? '');
    _dateOfBirth = TextEditingController(text: profile?.dateOfBirth ?? '');
    _gender = TextEditingController(text: profile?.gender ?? '');
    _bloodType = TextEditingController(text: profile?.bloodType ?? '');
    _heightCm = TextEditingController(text: profile?.heightCm?.toStringAsFixed(0) ?? '');
    _weightKg = TextEditingController(text: profile?.weightKg?.toStringAsFixed(1) ?? '');
    _allergies = TextEditingController(text: profile?.allergies ?? '');
    _chronicDiseases = TextEditingController(text: profile?.chronicDiseases ?? '');
    _emergencyName = TextEditingController(text: profile?.emergencyContactName ?? '');
    _emergencyPhone = TextEditingController(text: profile?.emergencyContactPhone ?? '');
    _address = TextEditingController(text: profile?.address ?? '');
    _insuranceNumber = TextEditingController(text: profile?.insuranceNumber ?? '');
    _occupation = TextEditingController(text: profile?.occupation ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _firstName, _lastName, _middleName, _phone, _dateOfBirth,
      _gender, _bloodType, _heightCm, _weightKg, _allergies,
      _chronicDiseases, _emergencyName, _emergencyPhone, _address,
      _insuranceNumber, _occupation,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _saveError = null; });
    try {
      final body = <String, dynamic>{
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        if (_middleName.text.trim().isNotEmpty) 'middleName': _middleName.text.trim(),
        if (_phone.text.trim().isNotEmpty) 'phoneNumber': _phone.text.trim(),
        if (_dateOfBirth.text.trim().isNotEmpty) 'dateOfBirth': _dateOfBirth.text.trim(),
        if (_gender.text.trim().isNotEmpty) 'gender': _gender.text.trim(),
        if (_bloodType.text.trim().isNotEmpty) 'bloodType': _bloodType.text.trim(),
        if (_heightCm.text.trim().isNotEmpty) 'heightCm': double.tryParse(_heightCm.text.trim()),
        if (_weightKg.text.trim().isNotEmpty) 'weightKg': double.tryParse(_weightKg.text.trim()),
        if (_allergies.text.trim().isNotEmpty) 'allergies': _allergies.text.trim(),
        if (_chronicDiseases.text.trim().isNotEmpty) 'chronicDiseases': _chronicDiseases.text.trim(),
        if (_emergencyName.text.trim().isNotEmpty) 'emergencyContactName': _emergencyName.text.trim(),
        if (_emergencyPhone.text.trim().isNotEmpty) 'emergencyContactPhone': _emergencyPhone.text.trim(),
        if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
        if (_insuranceNumber.text.trim().isNotEmpty) 'insuranceNumber': _insuranceNumber.text.trim(),
        if (_occupation.text.trim().isNotEmpty) 'occupation': _occupation.text.trim(),
      };
      await ref.read(profileDatasourceProvider).updatePatientProfile(body);
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
    // Следим за языком — при смене виджет перестроится
    final locale = ref.watch(localeProvider);
    S.setLocale(AppLocale.values.firstWhere(
          (e) => e.name == locale.languageCode,
      orElse: () => AppLocale.ru,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: Text(S.editProfile),
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
              if (_saveError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_saveError!, style: const TextStyle(color: Color(0xFFC62828), fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              _sectionHeader(S.personalInfo),
              _field(S.firstName, _firstName, validator: _required, capitalization: TextCapitalization.words),
              _field(S.lastName, _lastName, validator: _required, capitalization: TextCapitalization.words),
              _field(S.middleName, _middleName, capitalization: TextCapitalization.words),
              _field(S.phone, _phone, keyboard: TextInputType.phone),
              _field(S.dateOfBirth, _dateOfBirth, hint: 'YYYY-MM-DD', keyboard: TextInputType.datetime),
              _field(S.occupation, _occupation, capitalization: TextCapitalization.words),
              _field(S.address, _address, capitalization: TextCapitalization.sentences),

              _sectionHeader(S.medicalInfo),
              _field(S.gender, _gender, hint: 'MALE / FEMALE / OTHER'),
              _field(S.bloodType, _bloodType, hint: 'A_POSITIVE / B_NEGATIVE / etc.'),
              _field(S.height, _heightCm, keyboard: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly]),
              _field(S.weight, _weightKg, keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field(S.allergies, _allergies, maxLines: 2, capitalization: TextCapitalization.sentences),
              _field(S.chronicDiseases, _chronicDiseases, maxLines: 2, capitalization: TextCapitalization.sentences),

              _sectionHeader(S.emergencyContact),
              _field(S.contactName, _emergencyName, capitalization: TextCapitalization.words),
              _field(S.contactPhone, _emergencyPhone, keyboard: TextInputType.phone),

              _sectionHeader(S.insurance),
              _field(S.insuranceNumber, _insuranceNumber),

              const SizedBox(height: 24),

              // Language switcher
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.language, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final lang in [('RU', 'ru'), ('KZ', 'kk'), ('EN', 'en')])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: OutlinedButton(
                                onPressed: () => ref.read(localeProvider.notifier).setLocale(Locale(lang.$2)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: locale.languageCode == lang.$2 ? AppColors.primary : null,
                                  foregroundColor: locale.languageCode == lang.$2 ? Colors.white : AppColors.primary,
                                ),
                                child: Text(lang.$1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              AppButton(
                label: S.saveChanges,
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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8), letterSpacing: 0.4)),
    );
  }

  Widget _field(String label, TextEditingController controller, {
    String? hint, TextInputType? keyboard, int maxLines = 1,
    String? Function(String?)? validator, List<TextInputFormatter>? formatters,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? S.required : null;
}