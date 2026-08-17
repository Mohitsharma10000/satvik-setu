import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/subcategory_model.dart';
import 'subcategory_providers.dart';
import '../categories/category_providers.dart';

class SubcategoryFormDialog extends ConsumerStatefulWidget {
  final SubcategoryModel? subcategory;

  const SubcategoryFormDialog({super.key, this.subcategory});

  @override
  ConsumerState<SubcategoryFormDialog> createState() => _SubcategoryFormDialogState();
}

class _SubcategoryFormDialogState extends ConsumerState<SubcategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _orderController;
  String? _selectedCategoryId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subcategory?.name ?? '');
    _orderController = TextEditingController(text: widget.subcategory?.order.toString() ?? '0');
    _selectedCategoryId = widget.subcategory?.categoryId;
    _isActive = widget.subcategory?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final repo = ref.read(subcategoryRepositoryProvider);
      
      final model = SubcategoryModel(
        id: widget.subcategory?.id ?? '',
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        order: int.tryParse(_orderController.text) ?? 0,
        isActive: _isActive,
        createdAt: widget.subcategory?.createdAt,
      );

      if (widget.subcategory == null) {
        await repo.addSubcategory(model);
      } else {
        await repo.updateSubcategory(model);
      }
      
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return AlertDialog(
      title: Text(widget.subcategory == null ? 'Add Subcategory' : 'Edit Subcategory'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            categoriesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
              data: (categories) {
                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Parent Category', border: OutlineInputBorder()),
                  items: categories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  validator: (v) => v == null ? 'Required' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orderController,
              decoration: const InputDecoration(labelText: 'Order', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
