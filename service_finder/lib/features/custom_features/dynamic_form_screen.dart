import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/dynamic_feature_model.dart';
import '../../services/guest_id_service.dart';

final dynamicFeatureDetailProvider = FutureProvider.family<DynamicFeatureModel?, String>((ref, featureId) async {
  final doc = await FirebaseFirestore.instance.collection('dynamic_features').doc(featureId).get();
  if (doc.exists) {
    return DynamicFeatureModel.fromFirestore(doc);
  }
  return null;
});

class DynamicFormScreen extends ConsumerStatefulWidget {
  final String featureId;
  final DynamicFeatureModel? featureModel;

  const DynamicFormScreen({
    super.key,
    required this.featureId,
    this.featureModel,
  });

  @override
  ConsumerState<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends ConsumerState<DynamicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formValues = {};
  bool _isSubmitting = false;

  Future<void> _selectDate(BuildContext context, String fieldLabel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _formValues[fieldLabel] = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm(DynamicFeatureModel feature) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    try {
      final guestId = await GuestIdService.getGuestId();

      await FirebaseFirestore.instance.collection('custom_feature_submissions').add({
        'featureId': feature.id,
        'featureName': feature.featureName,
        'guestId': guestId,
        'submittedAt': FieldValue.serverTimestamp(),
        'responseMap': _formValues,
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('🎉 Request Submitted!'),
            content: Text(
              'Thank you! Your request for "${feature.featureName}" has been received successfully.\n\n'
              'Our team / provider will get back to you shortly.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featureModel != null) {
      return _buildFormScaffold(widget.featureModel!);
    }

    final featureAsync = ref.watch(dynamicFeatureDetailProvider(widget.featureId));

    return featureAsync.when(
      loading: () => Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('Error: $err'))),
      data: (feature) {
        if (feature == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Feature Not Found')),
            body: const Center(child: Text('This feature is no longer available.')),
          );
        }
        return _buildFormScaffold(feature);
      },
    );
  }

  Widget _buildFormScaffold(DynamicFeatureModel feature) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(feature.featureName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Feature Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    feature.featureName,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  if (feature.badgeText.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade700,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        feature.badgeText,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feature.description,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Please fill in the details below:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // DYNAMICALLY RENDERED INPUT FIELDS
                ...feature.fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: _buildDynamicInputField(field),
                  );
                }),

                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : () => _submitForm(feature),
                    icon: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit Request',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicInputField(CustomFormFieldModel field) {
    if (field.type == 'dropdown') {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
          filled: true,
        ),
        items: field.options.map((opt) {
          return DropdownMenuItem(value: opt, child: Text(opt));
        }).toList(),
        onChanged: (val) {
          _formValues[field.label] = val;
        },
        validator: (val) {
          if (field.isRequired && (val == null || val.isEmpty)) {
            return 'Please select ${field.label}';
          }
          return null;
        },
      );
    }

    if (field.type == 'date') {
      final valStr = _formValues[field.label] as String?;
      return InkWell(
        onTap: () => _selectDate(context, field.label),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.calendar_today),
            filled: true,
          ),
          child: Text(
            valStr ?? 'Tap to select date',
            style: TextStyle(color: valStr != null ? Colors.black : Colors.grey.shade600),
          ),
        ),
      );
    }

    return TextFormField(
      keyboardType: field.type == 'number'
          ? TextInputType.number
          : field.type == 'phone'
              ? TextInputType.phone
              : TextInputType.text,
      maxLines: field.type == 'multiline' ? 4 : 1,
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      onSaved: (val) => _formValues[field.label] = val?.trim(),
      validator: (val) {
        if (field.isRequired && (val == null || val.trim().isEmpty)) {
          return 'Please enter ${field.label}';
        }
        return null;
      },
    );
  }
}
