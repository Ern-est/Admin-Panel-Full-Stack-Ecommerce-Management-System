import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_panel/core/config.dart';

class EditBannerPopup extends StatefulWidget {
  final Map<String, dynamic> bannerData;
  final VoidCallback onSaved;

  const EditBannerPopup({
    super.key,
    required this.bannerData,
    required this.onSaved,
  });

  @override
  State<EditBannerPopup> createState() => _EditBannerPopupState();
}

class _EditBannerPopupState extends State<EditBannerPopup> {
  late TextEditingController _titleController;
  XFile? _imageFile;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bannerData['title']);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _updateBanner() async {
    setState(() => _isSaving = true);
    String? imageUrl = widget.bannerData['image_url'];

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

      await AppConfig.supabase
          .from('banners')
          .update({
            'title': _titleController.text.trim(),
            'image_url': imageUrl,
          })
          .eq('id', widget.bannerData['id']);

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error updating banner: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Banner"),
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
            child: Text(_imageFile == null ? "Pick New Image" : "Change Image"),
          ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.file(File(_imageFile!.path), height: 100),
            ),
          if (_imageFile == null && widget.bannerData['image_url'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.network(widget.bannerData['image_url'], height: 100),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _updateBanner,
          child:
              _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Update"),
        ),
      ],
    );
  }
}
