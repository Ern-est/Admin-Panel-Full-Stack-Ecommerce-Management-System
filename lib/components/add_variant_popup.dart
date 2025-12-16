import 'package:flutter/material.dart';
import 'package:admin_panel/core/config.dart';

class AddVariantPopup extends StatefulWidget {
  final List<dynamic> variantTypes;
  final VoidCallback onSaved;

  const AddVariantPopup({
    super.key,
    required this.variantTypes,
    required this.onSaved,
  });

  @override
  State<AddVariantPopup> createState() => _AddVariantPopupState();
}

class _AddVariantPopupState extends State<AddVariantPopup> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  int? selectedTypeId;
  bool status = true;
  bool isSaving = false;

  Future<void> saveVariant() async {
    if (!_formKey.currentState!.validate() || selectedTypeId == null) return;

    setState(() => isSaving = true);

    try {
      await AppConfig.supabase.from('variants').insert({
        'name': name,
        'variant_type_id': selectedTypeId,
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
      });

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error adding variant: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add variant')));
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Variant"),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Variant Name"),
                onChanged: (val) => name = val,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Enter variant name"
                            : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Variant Type"),
                items:
                    widget.variantTypes
                        .map(
                          (type) => DropdownMenuItem<int>(
                            value: type['id'],
                            child: Text(type['name'] ?? ''),
                          ),
                        )
                        .toList(),
                onChanged: (val) => selectedTypeId = val,
                validator:
                    (val) => val == null ? "Select a variant type" : null,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Active"),
                  Switch(
                    value: status,
                    onChanged: (val) => setState(() => status = val),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : saveVariant,
          child:
              isSaving
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text("Save"),
        ),
      ],
    );
  }
}
