import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_panel/core/config.dart';

class EditNotificationPopup extends StatefulWidget {
  final Map<String, dynamic> notificationData;
  final VoidCallback onSaved;

  const EditNotificationPopup({
    super.key,
    required this.notificationData,
    required this.onSaved,
  });

  @override
  State<EditNotificationPopup> createState() => _EditNotificationPopupState();
}

class _EditNotificationPopupState extends State<EditNotificationPopup> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  XFile? _imageFile;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.notificationData['title'],
    );
    _descriptionController = TextEditingController(
      text: widget.notificationData['description'],
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _updateNotification() async {
    setState(() => _isSaving = true);
    String? imageUrl = widget.notificationData['image_url'];

    try {
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

      await AppConfig.supabase
          .from('notifications')
          .update({
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'image_url': imageUrl,
          })
          .eq('id', widget.notificationData['id']);

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Update notification error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update notification")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Notification"),
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
            child: Text(_imageFile == null ? "Pick New Image" : "Change Image"),
          ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.file(File(_imageFile!.path), height: 100),
            ),
          if (_imageFile == null &&
              widget.notificationData['image_url'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.network(
                widget.notificationData['image_url'],
                height: 100,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _updateNotification,
          child:
              _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Update"),
        ),
      ],
    );
  }
}
