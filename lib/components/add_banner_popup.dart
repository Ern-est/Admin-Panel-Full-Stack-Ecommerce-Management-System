import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_panel/core/config.dart';

class AddBannerPopup extends StatefulWidget {
  final VoidCallback onSaved;

  const AddBannerPopup({super.key, required this.onSaved});

  @override
  State<AddBannerPopup> createState() => _AddBannerPopupState();
}

class _AddBannerPopupState extends State<AddBannerPopup> {
  final TextEditingController _titleController = TextEditingController();
  XFile? _imageFile;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _saveBanner() async {
    if (_titleController.text.isEmpty) return;

    setState(() => _isSaving = true);
    String? imageUrl;

    try {
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}';
        await AppConfig.supabase.storage
            .from('banner-images')
            .uploadBinary(fileName, bytes);

        imageUrl = AppConfig.supabase.storage
            .from('banner-images')
            .getPublicUrl(fileName);
      }

      await AppConfig.supabase.from('banners').insert({
        'title': _titleController.text.trim(),
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error saving banner: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Banner"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Title"),
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
          onPressed: _isSaving ? null : _saveBanner,
          child:
              _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save"),
        ),
      ],
    );
  }
}
