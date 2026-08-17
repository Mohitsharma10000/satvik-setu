import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/admin_shell.dart';
import 'application_providers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/image_viewer_dialog.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../utils/base64_image_helper.dart';

class ApplicationDetailPage extends ConsumerWidget {
  final String id;
  const ApplicationDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appAsync = ref.watch(applicationDetailProvider(id));

    return AdminShell(
      child: appAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (app) {
          if (app == null) return const Center(child: Text('Application not found.'));
          
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: const Text('Application Details'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(child: StatusBadge(status: app.verificationStatus)),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Personal Information'),
                        _buildInfoRow('Name', app.name),
                        _buildInfoRow('Phone', app.phone),
                        _buildInfoRow('Email', app.email),
                        _buildInfoRow('Gender', app.gender),
                        _buildInfoRow('DOB', app.dob),
                        _buildInfoRow('Address', '${app.address}, ${app.city}, ${app.state} - ${app.pincode}'),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Professional Information'),
                        _buildInfoRow('Category', app.category),
                        _buildInfoRow('Subcategory', app.subcategory),
                        _buildInfoRow('Experience', app.experience),
                        _buildInfoRow('Description', app.description),
                        if (app.serviceRate != null) _buildInfoRow('Service Charge / Rate', '₹${app.serviceRate}'),
                        if (app.rateDescription != null) _buildInfoRow('Rate Desc', app.rateDescription!),
                        if (app.latitude != null && app.longitude != null) _buildInfoRow('Location', '${app.latitude}, ${app.longitude}'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Documents'),
                        _buildDocumentImage(context, 'Profile Image', app.profileImage),
                        _buildDocumentImage(context, 'Aadhaar Front', app.aadhaarFront),
                        _buildDocumentImage(context, 'Aadhaar Back', app.aadhaarBack),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _deleteApp(context, ref, app.id),
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 16),
                  if (app.verificationStatus != 'rejected')
                    OutlinedButton(
                      onPressed: () => _rejectApp(context, ref, app.id),
                      child: const Text('Reject', style: TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(width: 16),
                  if (app.verificationStatus != 'approved')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () => _approveApp(context, ref, app),
                      child: const Text('Approve'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildDocumentImage(BuildContext context, String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            if (url.isNotEmpty) {
              showDialog(context: context, builder: (_) => ImageViewerDialog(imageUrl: url));
            }
          },
          child: Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: url.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Base64ImageHelper.getImageWidget(url, fit: BoxFit.cover),
                  )
                : const Center(child: Text('No Image Provided')),
          ),
        ),
      ],
    );
  }

  void _approveApp(BuildContext context, WidgetRef ref, app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(
        title: 'Approve Application',
        message: 'Are you sure you want to approve this provider?',
      ),
    );
    if (confirm == true) {
      await ref.read(applicationRepositoryProvider).approveApplication(app);
      ref.invalidate(applicationDetailProvider(app.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Approved')));
    }
  }

  void _rejectApp(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(
        title: 'Reject Application',
        message: 'Are you sure you want to reject this application?',
        isDestructive: true,
      ),
    );
    if (confirm == true) {
      await ref.read(applicationRepositoryProvider).rejectApplication(id);
      ref.invalidate(applicationDetailProvider(id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected')));
    }
  }

  void _deleteApp(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(
        title: 'Delete Application',
        message: 'Are you sure you want to delete this application permanently?',
        isDestructive: true,
      ),
    );
    if (confirm == true) {
      await ref.read(applicationRepositoryProvider).deleteApplication(id);
      context.pop();
    }
  }
}
