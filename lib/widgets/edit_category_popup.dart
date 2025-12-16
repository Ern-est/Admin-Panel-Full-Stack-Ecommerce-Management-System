import 'package:flutter/material.dart';
import '../core/config.dart';

class EditCategoryPopup extends StatefulWidget {
  final Map<String, dynamic> category;
  final Future<void> Function() onSave;

  const EditCategoryPopup({
    super.key,
    required this.category,
    required this.onSave,
  });

  @override
  State<EditCategoryPopup> createState() => _EditCategoryPopupState();
}

class _EditCategoryPopupState extends State<EditCategoryPopup> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.category['name']);
  }

  Future<void> saveChanges() async {
    await AppConfig.supabase
        .from('categories')
        .update({'name': nameController.text.trim()})
        .eq('id', widget.category['id']); // UUID as String

    Navigator.pop(context);
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF181A1F),
      title: const Text("Edit Category", style: TextStyle(color: Colors.white)),
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
        ElevatedButton(onPressed: saveChanges, child: const Text("Save")),
      ],
    );
  }
}
