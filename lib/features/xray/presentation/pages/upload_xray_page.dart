import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/xray_upload_provider.dart';

class UploadXrayPage extends ConsumerStatefulWidget {
  const UploadXrayPage({super.key});

  @override
  ConsumerState<UploadXrayPage> createState() => _UploadXrayPageState();
}

class _UploadXrayPageState extends ConsumerState<UploadXrayPage> {
  File? _selectedFile;
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
  try {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null) return; // User cancelled — not an error.

    final file = File(picked.path);
    final size = await file.length();

    if (size > AppConstants.maxXrayFileSizeBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File is too large. Maximum size is 20MB.'),
          ),
        );
      }
      return;
    }

    setState(() => _selectedFile = file);
  } catch (e) {
    // image_picker throws UnimplementedError on Windows desktop.
    // On device this catch should never fire for normal use.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('UnimplementedError') ||
                    e.toString().contains('MissingPluginException')
                ? 'Image picker is not supported on this platform. Run on Android or iOS.'
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
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    ),
  );

  if (source != null) {
    await _pickImage(source);
  }
}

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(xrayUploadProvider);

    // Navigate to result when upload succeeds
    ref.listen<UploadState>(xrayUploadProvider, (_, next) {
      if (next is UploadSuccess) {
        context.go('/xray/${next.xrayId}');
      }
    });

    final isUploading = uploadState is UploadInProgress;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Upload X-Ray'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image selector
            GestureDetector(
              onTap: isUploading ? null : _showSourcePicker,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFile != null
                        ? const Color(0xFF1A73E8)
                        : Colors.grey.shade300,
                    width: _selectedFile != null ? 2 : 1,
                  ),
                ),
                child: _selectedFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(_selectedFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file_outlined,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('Tap to select X-ray image',
                              style: TextStyle(color: Colors.grey.shade500)),
                          const SizedBox(height: 4),
                          Text('Gallery or Camera',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade400)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes field
            TextField(
              controller: _notesController,
              enabled: !isUploading,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Patient Notes (optional)',
                hintText: 'Describe symptoms, duration, etc.',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upload progress
            if (uploadState is UploadInProgress) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: uploadState.progress > 0 ? uploadState.progress : null,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF1A73E8)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  uploadState.progress > 0
                      ? 'Uploading ${(uploadState.progress * 100).round()}%...'
                      : 'Preparing upload...',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Error
            if (uploadState is UploadError) ...[
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
                      child: Text(
                        uploadState.message,
                        style: const TextStyle(
                            color: Color(0xFFC62828), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: (_selectedFile == null || isUploading)
                    ? null
                    : () => ref.read(xrayUploadProvider.notifier).upload(
                          file: _selectedFile!,
                          patientNotes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white)),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(isUploading ? 'Uploading...' : 'Analyze X-Ray'),
              ),
            ),
            if (_selectedFile == null && !isUploading) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Select an X-ray image above to continue',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
          ],
        ),
      ),
    );
  }
}