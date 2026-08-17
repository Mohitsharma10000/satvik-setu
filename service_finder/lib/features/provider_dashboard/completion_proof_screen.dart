import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../repositories/service_request_repository.dart';

class CompletionProofScreen extends ConsumerStatefulWidget {
  final String requestId;

  const CompletionProofScreen({super.key, required this.requestId});

  @override
  ConsumerState<CompletionProofScreen> createState() => _CompletionProofScreenState();
}

class _CompletionProofScreenState extends ConsumerState<CompletionProofScreen> {
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  File? _beforePhoto;
  File? _afterPhoto;
  File? _invoicePhoto;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, Function(File) onPicked) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        onPicked(File(picked.path));
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  Future<void> _submitProof() async {
    if (_beforePhoto == null || _afterPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take both BEFORE and AFTER work photos as mandatory completion proof.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final repo = ref.read(serviceRequestRepositoryProvider);

    try {
      final beforeBase64 = await _fileToBase64(_beforePhoto!);
      final afterBase64 = await _fileToBase64(_afterPhoto!);
      String? invoiceBase64;
      if (_invoicePhoto != null) {
        invoiceBase64 = await _fileToBase64(_invoicePhoto!);
      }

      await repo.addCompletionProof(
        widget.requestId,
        beforePhotos: [beforeBase64],
        afterPhotos: [afterBase64],
        completionPhotos: [beforeBase64, afterBase64],
        completionNotes: _notesController.text.trim(),
        invoice: invoiceBase64,
      );

      await repo.markCompleted(widget.requestId);

      if (mounted) {
        setState(() => _isSubmitting = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('🎉 Work Completed!'),
            content: const Text(
              'Mandatory work completion proof uploaded successfully.\n\n'
              'The customer and admin can now view the before/after proof.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit proof: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildPhotoPickerTile({
    required String title,
    required String subtitle,
    required File? file,
    required Function(File) onPicked,
    bool isMandatory = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (isMandatory) ...[
                  const SizedBox(width: 4),
                  const Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            if (file != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(file, height: 160, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      style: IconButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () => setState(() {
                        if (title.contains('Before')) _beforePhoto = null;
                        if (title.contains('After')) _afterPhoto = null;
                        if (title.contains('Invoice')) _invoicePhoto = null;
                      }),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera, onPicked),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Camera Photo'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery, onPicked),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose Gallery'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mandatory Work Completion Proof')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Before & After photos are mandatory to verify job completion for customer and admin records.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildPhotoPickerTile(
              title: 'Before Work Photo',
              subtitle: 'Capture the problem / site state before starting repair',
              file: _beforePhoto,
              onPicked: (f) => _beforePhoto = f,
              isMandatory: true,
            ),

            _buildPhotoPickerTile(
              title: 'After Work Photo',
              subtitle: 'Capture the completed repair / installed unit',
              file: _afterPhoto,
              onPicked: (f) => _afterPhoto = f,
              isMandatory: true,
            ),

            _buildPhotoPickerTile(
              title: 'Optional Invoice / Bill Photo',
              subtitle: 'Capture paper bill or receipt if provided to customer',
              file: _invoicePhoto,
              onPicked: (f) => _invoicePhoto = f,
              isMandatory: false,
            ),

            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Completion Notes / Summary of Work Done',
                hintText: 'e.g. Fixed short circuit, replaced 25A MCB fuse, tested wiring load.',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitProof,
                icon: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.check_circle),
                label: Text(_isSubmitting ? 'Uploading Proof...' : 'Submit Proof & Complete Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
