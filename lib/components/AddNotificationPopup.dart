import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_panel/core/config.dart';

class AddNotificationPopup extends StatefulWidget {
  final VoidCallback onSaved;

  const AddNotificationPopup({super.key, required this.onSaved});

  @override
  State<AddNotificationPopup> createState() => _AddNotificationPopupState();
}

class _AddNotificationPopupState extends State<AddNotificationPopup> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _imageFile;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _saveNotification() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty)
      return;

    setState(() => _isSaving = true);
    String? imageUrl;

    try {
      // Upload image only on save
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}';
        await AppConfig.supabase.storage
            .from('notification-images')
            .uploadBinary(fileName, bytes);

        imageUrl = AppConfig.supabase.storage
            .from('notification-images')
            .getPublicUrl(fileName);
      }

      await AppConfig.supabase.from('notifications').insert({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image_url': imageUrl,
        'status': 'draft',
        'created_at': DateTime.now().toIso8601String(),
      });

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Save notification error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save notification")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Notification"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text(_imageFile == null ? "Pick Image" : "Change Image"),
          ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.file(File(_imageFile!.path), height: 100),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveNotification,
          child:
              _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save"),
        ),
      ],
    );
  }
}
