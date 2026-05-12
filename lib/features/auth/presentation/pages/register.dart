import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _error = null; });
    try {
      final config = ref.read(envConfigProvider);
      final dio = Dio(BaseOptions(baseUrl: config.gatewayBaseUrl));
      final data = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      };
      if (_phoneController.text.trim().isNotEmpty) {
        data['phoneNumber'] = _phoneController.text.trim();
      }
      await dio.post(ApiPaths.registerPatient, data: data);
      FocusScope.of(context).unfocus();
      setState(() { _success = true; });
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.response?.data?.toString() ?? e.message ?? 'Registration failed';
      setState(() { _error = msg.toString(); });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    S.setLocale(AppLocale.values.firstWhere(
          (e) => e.name == locale.languageCode,
      orElse: () => AppLocale.ru,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFF0C1A2E),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.navy),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 56),
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Padding(padding: const EdgeInsets.all(10), child: Image.asset('assets/images/logo.png', fit: BoxFit.contain)),
                  ),
                  const SizedBox(height: 20),
                  const Text('TynysAI', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.all(28),
                    child: _success ? _buildSuccess() : _buildForm(),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(S.alreadyHaveAccount, style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
        const SizedBox(height: 16),
        Text(S.registrationSuccess, style: AppText.displayMd),
        const SizedBox(height: 8),
        Text(S.canSignIn, style: AppText.bodySm, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        GradientButton(label: S.goToLogin, onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.createAccount, style: AppText.displayMd),
          const SizedBox(height: 4),
          Text(S.registerAsPatient, style: AppText.bodySm),
          const SizedBox(height: 24),
          TextFormField(
            controller: _firstNameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: S.firstName, prefixIcon: const Icon(Icons.person_outline, size: 20)),
            validator: (v) => v == null || v.trim().isEmpty ? S.required : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _lastNameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: S.lastName, prefixIcon: const Icon(Icons.person_outline, size: 20)),
            validator: (v) => v == null || v.trim().isEmpty ? S.required : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: S.email, prefixIcon: const Icon(Icons.email_outlined, size: 20)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return S.emailRequired;
              if (!v.contains('@')) return S.emailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: S.phoneOptional, prefixIcon: const Icon(Icons.phone_outlined, size: 20), hintText: '+77001234567'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (!RegExp(r'^\+?[1-9]\d{6,14}$').hasMatch(v.trim())) return S.invalidPhone;
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: S.password,
              prefixIcon: const Icon(Icons.lock_outlined, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return S.passwordRequired;
              if (v.length < 6) return S.passwordMin;
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: AppText.bodySm.copyWith(color: AppColors.error))),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          GradientButton(label: S.createAccount, isLoading: _isLoading, onPressed: _isLoading ? null : _submit),
        ],
      ),
    );
  }
}