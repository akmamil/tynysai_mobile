import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../shared/widgets/step_indicator.dart';
import '../../../appointments/data/doctors_remote_datasource.dart';
import '../providers/xray_upload_provider.dart';

class UploadXrayPage extends ConsumerStatefulWidget {
  const UploadXrayPage({super.key});

  @override
  ConsumerState<UploadXrayPage> createState() => _UploadXrayPageState();
}

class _UploadXrayPageState extends ConsumerState<UploadXrayPage> {
  File? _selectedFile;
  String? _selectedDoctorId;
  bool _doctorError = false;
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;

      final file = File(picked.path);
      final size = await file.length();

      if (size > AppConstants.maxXrayFileSizeBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File is too large. Maximum size is 20 MB.')),
          );
        }
        return;
      }

      setState(() => _selectedFile = file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('UnimplementedError') || e.toString().contains('MissingPluginException')
                  ? 'Image picker is not supported on this platform.'
                  : 'Could not open image picker. Try again.',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _showSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Select source', style: AppText.h3),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primary, size: 20),
              ),
              title: const Text('Choose from Gallery', style: AppText.bodyMd),
              subtitle: Text('JPG, PNG up to 20 MB', style: AppText.bodyXs),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.teal, size: 20),
              ),
              title: const Text('Take Photo', style: AppText.bodyMd),
              subtitle: Text('Use camera directly', style: AppText.bodyXs),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source != null) await _pickImage(source);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    S.setLocale(AppLocale.values.firstWhere(
          (e) => e.name == locale.languageCode,
      orElse: () => AppLocale.ru,
    ));

    final uploadState = ref.watch(xrayUploadProvider);

    ref.listen<UploadState>(xrayUploadProvider, (_, next) {
      if (next is UploadSuccess) {
        context.go('/xray/${next.xrayId}');
      }
    });

    final isUploading = uploadState is UploadInProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.uploadXray)),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── How it works ──────────────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.howItWorks, style: AppText.h3),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      StepIndicator(number: 1, label: 'Upload X-Ray', sub: 'JPG or PNG\nup to 20 MB'),
                      StepIndicator(number: 2, label: 'AI Analyzes', sub: 'Neural network\nclassifies'),
                      StepIndicator(number: 3, label: 'Get Result', sub: 'Diagnosis +\nconfidence'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Drop zone ─────────────────────────────────────────────────
            GestureDetector(
              onTap: isUploading ? null : _showSourcePicker,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _selectedFile != null ? Colors.black : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedFile != null
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.3),
                    width: _selectedFile != null ? 2 : 1.5,
                  ),
                ),
                child: _selectedFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_selectedFile!, fit: BoxFit.contain),
                      Positioned(
                        bottom: 10, right: 10,
                        child: GestureDetector(
                          onTap: isUploading ? null : _showSourcePicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.swap_horiz_outlined, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('Change', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.upload_file_outlined,
                          size: 28, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text('Tap to select X-ray image',
                        style: AppText.bodyMd.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('JPG or PNG  ·  Gallery or Camera', style: AppText.bodyXs),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Doctor selector (required) ────────────────────────────────
            Consumer(
              builder: (context, ref, _) {
                final doctorsAsync = ref.watch(approvedDoctorsProvider);
                return doctorsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Could not load doctors',
                      style: AppText.bodySm.copyWith(color: AppColors.error)),
                  data: (doctors) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedDoctorId,
                        decoration: InputDecoration(
                          labelText: 'Assign Doctor *',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: _doctorError ? AppColors.error : AppColors.border)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.error)),
                        ),
                        hint: const Text('Select a doctor'),
                        isExpanded: true,
                        items: doctors.map((d) => DropdownMenuItem(
                          value: d.userId,
                          child: Text(
                            '${d.fullName}${d.specialization != null ? ' - ${d.specialization}' : ''}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )).toList(),
                        onChanged: isUploading
                            ? null
                            : (v) => setState(() {
                          _selectedDoctorId = v;
                          _doctorError = false;
                        }),
                      ),
                      if (_doctorError) ...[
                        const SizedBox(height: 4),
                        const Text('Please select a doctor',
                            style: TextStyle(color: AppColors.error, fontSize: 12)),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // ── Notes field ───────────────────────────────────────────────
            TextField(
              controller: _notesController,
              enabled: !isUploading,
              maxLines: 3,
              style: AppText.bodyMd,
              decoration: InputDecoration(
                labelText: 'Patient Notes (optional)',
                hintText: 'Describe symptoms, duration, medical history...',
                filled: true,
                fillColor: AppColors.surface,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 24),

            // ── Upload progress ───────────────────────────────────────────
            if (uploadState is UploadInProgress) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: uploadState.progress > 0 ? uploadState.progress : null,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  uploadState.progress > 0
                      ? 'Uploading ${(uploadState.progress * 100).round()}%...'
                      : 'Preparing upload...',
                  style: AppText.bodySm,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Error state ───────────────────────────────────────────────
            if (uploadState is UploadError) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.failedBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(uploadState.message,
                            style: AppText.bodySm.copyWith(color: AppColors.failedText))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Submit button ─────────────────────────────────────────────
            GradientButton(
              label: isUploading ? 'Uploading...' : S.analyzeXray,
              icon: isUploading ? null : Icons.cloud_upload_outlined,
              isLoading: isUploading,
              onPressed: (_selectedFile == null || isUploading)
                  ? null
                  : () {
                if (_selectedDoctorId == null) {
                  setState(() => _doctorError = true);
                  return;
                }
                ref.read(xrayUploadProvider.notifier).upload(
                  file: _selectedFile!,
                  patientNotes: _notesController.text.trim().isEmpty
                      ? null
                      : _notesController.text.trim(),
                  assignedDoctorId: _selectedDoctorId,
                );
              },
            ),

            if (_selectedFile == null && !isUploading) ...[
              const SizedBox(height: 10),
              Center(
                  child: Text('Select an X-ray image above to continue',
                      style: AppText.bodySm)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}