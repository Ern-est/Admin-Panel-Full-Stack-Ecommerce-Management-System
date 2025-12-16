import 'package:flutter/material.dart';

class AddCategoryPopup extends StatefulWidget {
  final void Function(String name) onSave;

  const AddCategoryPopup({super.key, required this.onSave});

  @override
  State<AddCategoryPopup> createState() => _AddCategoryPopupState();
}

class _AddCategoryPopupState extends State<AddCategoryPopup> {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF181A1F),
      title: const Text("Add Category", style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: "Category Name",
          labelStyle: TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(nameController.text.trim());
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
