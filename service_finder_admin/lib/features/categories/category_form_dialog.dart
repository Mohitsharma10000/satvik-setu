import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category_model.dart';
import 'category_providers.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final CategoryModel? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _orderController;
  late TextEditingController _iconController;
  late TextEditingController _feeController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _orderController = TextEditingController(text: widget.category?.order.toString() ?? '0');
    _iconController = TextEditingController(text: widget.category?.icon ?? Icons.category.codePoint.toString());
    _feeController = TextEditingController(text: (widget.category?.advanceFee ?? 10.0).toStringAsFixed(0));
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    _iconController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(categoryRepositoryProvider);
      
      final model = CategoryModel(
        id: widget.category?.id ?? '',
        name: _nameController.text.trim(),
        icon: _iconController.text.trim(),
        order: int.tryParse(_orderController.text) ?? 0,
        advanceFee: double.tryParse(_feeController.text.trim()) ?? 10.0,
        isActive: _isActive,
        createdAt: widget.category?.createdAt,
      );

      if (widget.category == null) {
        await repo.addCategory(model);
      } else {
        await repo.updateCategory(model);
      }
      
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Advance Fee (₹)',
                  hintText: 'e.g. 10, 20, 50',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                  helperText: 'Amount users pay to view providers in this category',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final fee = double.tryParse(v.trim());
                  if (fee == null || fee <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _iconController,
                decoration: const InputDecoration(labelText: 'Icon CodePoint (e.g. 58348)', border: OutlineInputBorder()),
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
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
