import 'package:flutter/material.dart';
import '../core/config.dart';

class EditSubCategoryPopup extends StatefulWidget {
  final Map<String, dynamic> subcategory;
  final List<Map<String, dynamic>> categories;
  final Future<void> Function() onSave;

  const EditSubCategoryPopup({
    super.key,
    required this.subcategory,
    required this.categories,
    required this.onSave,
  });

  @override
  State<EditSubCategoryPopup> createState() => _EditSubCategoryPopupState();
}

class _EditSubCategoryPopupState extends State<EditSubCategoryPopup> {
  late TextEditingController nameController;
  String? categoryId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.subcategory['name']);
    categoryId = widget.subcategory['category_id'] as String?;
  }

  Future<void> saveChanges() async {
    await AppConfig.supabase
        .from('subcategories')
        .update({'name': nameController.text.trim(), 'category_id': categoryId})
        .eq('id', widget.subcategory['id'] as String);

    Navigator.pop(context);
    await widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF181A1F),
      title: const Text(
        "Edit Sub-Category",
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Sub-Category Name",
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: categoryId,
            dropdownColor: const Color(0xFF181A1F),
            items:
                widget.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id'] as String,
                    child: Text(
                      cat['name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
            onChanged: (value) => setState(() => categoryId = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(onPressed: saveChanges, child: const Text("Save")),
      ],
    );
  }
}
