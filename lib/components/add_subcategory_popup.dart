import 'package:flutter/material.dart';

class AddSubCategoryPopup extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final void Function(String name, String categoryId) onSave;

  const AddSubCategoryPopup({
    super.key,
    required this.categories,
    required this.onSave,
  });

  @override
  State<AddSubCategoryPopup> createState() => _AddSubCategoryPopupState();
}

class _AddSubCategoryPopupState extends State<AddSubCategoryPopup> {
  final TextEditingController nameController = TextEditingController();
  String? categoryId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF181A1F),
      title: const Text(
        "Add Sub-Category",
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Sub-Category Name",
              labelStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            dropdownColor: const Color(0xFF181A1F),
            decoration: const InputDecoration(
              labelText: "Select Category",
              labelStyle: TextStyle(color: Colors.white70),
            ),
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
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty || categoryId == null)
              return;
            widget.onSave(nameController.text.trim(), categoryId!);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
