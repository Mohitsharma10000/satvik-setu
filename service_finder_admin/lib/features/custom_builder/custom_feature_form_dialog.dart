import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/dynamic_feature_model.dart';
import '../../core/providers/firebase_providers.dart';

class CustomFeatureFormDialog extends ConsumerStatefulWidget {
  final DynamicFeatureModel? feature;

  const CustomFeatureFormDialog({super.key, this.feature});

  @override
  ConsumerState<CustomFeatureFormDialog> createState() => _CustomFeatureFormDialogState();
}

class _CustomFeatureFormDialogState extends ConsumerState<CustomFeatureFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _badgeController;
  late TextEditingController _feeController;
  bool _isActive = true;
  bool _isLoading = false;

  final List<CustomFormFieldModel> _customFields = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.feature?.featureName ?? '');
    _descController = TextEditingController(text: widget.feature?.description ?? '');
    _badgeController = TextEditingController(text: widget.feature?.badgeText ?? 'NEW');
    _feeController = TextEditingController(text: (widget.feature?.fee ?? 0.0).toStringAsFixed(0));
    _isActive = widget.feature?.isActive ?? true;

    if (widget.feature != null) {
      _customFields.addAll(widget.feature!.fields);
    } else {
      // Default initial fields for any feature
      _customFields.add(CustomFormFieldModel(id: const Uuid().v4(), label: 'Your Full Name', type: 'text', isRequired: true));
      _customFields.add(CustomFormFieldModel(id: const Uuid().v4(), label: 'Contact Mobile Number', type: 'phone', isRequired: true));
      _customFields.add(CustomFormFieldModel(id: const Uuid().v4(), label: 'Service Requirement / Details', type: 'multiline', isRequired: true));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _badgeController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _addNewFieldDialog() {
    final labelCtrl = TextEditingController();
    String selectedType = 'text';
    bool requiredVal = true;
    final optionsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              title: const Text('➕ Add Custom Input Field'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Field Label Name',
                        hintText: 'e.g. Property Type, Preferred Date, Budget',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Input Type', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'text', child: Text('Single Line Text')),
                        DropdownMenuItem(value: 'multiline', child: Text('Multi-line Text / Details')),
                        DropdownMenuItem(value: 'number', child: Text('Number / Amount')),
                        DropdownMenuItem(value: 'phone', child: Text('Phone Number')),
                        DropdownMenuItem(value: 'date', child: Text('Date Picker')),
                        DropdownMenuItem(value: 'dropdown', child: Text('Dropdown Options')),
                      ],
                      onChanged: (val) => setDlgState(() => selectedType = val!),
                    ),
                    if (selectedType == 'dropdown') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: optionsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Dropdown Options (comma separated)',
                          hintText: 'e.g. 1 BHK, 2 BHK, Commercial Space',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Is Required Field?'),
                      value: requiredVal,
                      onChanged: (v) => setDlgState(() => requiredVal = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (labelCtrl.text.trim().isNotEmpty) {
                      final opts = selectedType == 'dropdown'
                          ? optionsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                          : <String>[];
                      setState(() {
                        _customFields.add(
                          CustomFormFieldModel(
                            id: const Uuid().v4(),
                            label: labelCtrl.text.trim(),
                            type: selectedType,
                            options: opts,
                            isRequired: requiredVal,
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add Field'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveFeature() async {
    if (!_formKey.currentState!.validate()) return;
    if (_customFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one input field for this feature form.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestore = ref.read(firestoreProvider);
      final model = DynamicFeatureModel(
        id: widget.feature?.id ?? '',
        featureName: _nameController.text.trim(),
        description: _descController.text.trim(),
        badgeText: _badgeController.text.trim().toUpperCase(),
        fee: double.tryParse(_feeController.text.trim()) ?? 0.0,
        isActive: _isActive,
        fields: _customFields,
        createdAt: widget.feature?.createdAt,
      );

      if (widget.feature == null) {
        await firestore.collection('dynamic_features').add(model.toFirestore());
      } else {
        await firestore.collection('dynamic_features').doc(widget.feature!.id).update(model.toFirestore());
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Dynamic Feature & Custom Form published successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.build_circle, color: Colors.indigo, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      widget.feature == null ? '⚡ Build Entirely New Feature / Form' : 'Edit Feature & Form Fields',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Create interactive modules & custom forms that instantly render in User App without updating the APK!',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Feature / Module Name',
                    hintText: 'e.g. Site Visit Booking, Emergency Callback, Custom Quotation',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Explain what users get when they use this feature',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _feeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Advance Fee (₹)',
                          hintText: '0 for free',
                          prefixIcon: Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _badgeController,
                        decoration: const InputDecoration(
                          labelText: 'Badge Tag (e.g. HOT, NEW, 24/7)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text('Show in User App Home Screen'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),

                // CUSTOM INPUT FIELDS LIST
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📋 Custom Interactive Form Fields',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Field'),
                      onPressed: _addNewFieldDialog,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_customFields.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Text('No form fields added yet. Click "+ Add Field" to create interactive inputs!'),
                  ),

                ..._customFields.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final field = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.grey.shade50,
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.indigo.shade100,
                        child: Text('${idx + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(field.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Type: ${field.type.toUpperCase()} | Required: ${field.isRequired ? "Yes" : "No"}'
                          '${field.options.isNotEmpty ? " | Options: ${field.options.join(', ')}" : ""}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            _customFields.removeAt(idx);
                          });
                        },
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.rocket_launch),
                      label: Text(_isLoading ? 'Publishing...' : 'Publish Feature to User App'),
                      onPressed: _isLoading ? null : _saveFeature,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
