import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_feature_model.dart';
import 'feature_providers.dart';

class FeatureFormDialog extends ConsumerStatefulWidget {
  final AppFeatureModel? feature;

  const FeatureFormDialog({super.key, this.feature});

  @override
  ConsumerState<FeatureFormDialog> createState() => _FeatureFormDialogState();
}

class _FeatureFormDialogState extends ConsumerState<FeatureFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _badgeController;
  late TextEditingController _orderController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.feature?.title ?? '');
    _descController = TextEditingController(text: widget.feature?.description ?? '');
    _badgeController = TextEditingController(text: widget.feature?.badgeText ?? 'NEW');
    _orderController = TextEditingController(text: (widget.feature?.order ?? 0).toString());
    _isActive = widget.feature?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _badgeController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(featureRepositoryProvider);

      final model = AppFeatureModel(
        id: widget.feature?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        badgeText: _badgeController.text.trim().toUpperCase(),
        order: int.tryParse(_orderController.text.trim()) ?? 0,
        isActive: _isActive,
        createdAt: widget.feature?.createdAt,
      );

      if (widget.feature == null) {
        await repo.addFeature(model);
      } else {
        await repo.updateFeature(model);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.feature == null ? '🚀 Add New Dynamic Feature' : 'Edit Feature / Banner'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Feature / Banner Title',
                  hintText: 'e.g. Emergency 24/7 Service, Special Offer',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description / Details',
                  hintText: 'Describe this feature or announcement for users',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _badgeController,
                decoration: const InputDecoration(
                  labelText: 'Badge Tag (e.g. NEW, HOT, PROMO, 24/7)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Display Order (0, 1, 2...)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Show in User App'),
                subtitle: Text(_isActive ? 'Active & Visible to users' : 'Hidden from users'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Save Feature'),
          onPressed: _save,
        ),
      ],
    );
  }
}
