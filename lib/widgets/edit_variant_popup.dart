import 'package:flutter/material.dart';
import 'package:admin_panel/core/config.dart';

class EditVariantPopup extends StatefulWidget {
  final Map data;
  final List<dynamic> variantTypes;
  final VoidCallback onSaved;

  const EditVariantPopup({
    super.key,
    required this.data,
    required this.variantTypes,
    required this.onSaved,
  });

  @override
  State<EditVariantPopup> createState() => _EditVariantPopupState();
}

class _EditVariantPopupState extends State<EditVariantPopup> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  int? selectedTypeId;
  late bool status;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    name = widget.data['name'] ?? '';
    selectedTypeId = widget.data['variant_type_id'];
    status = widget.data['status'] ?? true;
  }

  Future<void> updateVariant() async {
    if (!_formKey.currentState!.validate() || selectedTypeId == null) return;

    setState(() => isSaving = true);

    try {
      await AppConfig.supabase
          .from('variants')
          .update({
            'name': name,
            'variant_type_id': selectedTypeId,
            'status': status,
          })
          .eq('id', widget.data['id']);

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error updating variant: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update variant')));
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Variant"),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
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
                value: selectedTypeId,
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
          onPressed: isSaving ? null : updateVariant,
          child:
              isSaving
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text("Update"),
        ),
      ],
    );
  }
}
