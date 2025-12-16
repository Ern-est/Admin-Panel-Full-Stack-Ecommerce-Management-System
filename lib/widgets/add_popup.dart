import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPopup extends StatefulWidget {
  final String title;
  final void Function(
    String name,
    String description,
    double price,
    File? imageFile,
  )
  onSave;

  const AddPopup({super.key, required this.title, required this.onSave});

  @override
  State<AddPopup> createState() => _AddPopupState();
}

class _AddPopupState extends State<AddPopup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  File? imageFile;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF181A1F),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // IMAGE PREVIEW
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  imageFile == null
                      ? const Center(
                        child: Text(
                          "No Image Selected",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                      : Image.file(imageFile!, fit: BoxFit.cover),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            const SizedBox(height: 16),

            // PRODUCT NAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 12),

            // DESCRIPTION
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 12),

            // PRICE
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          onPressed: () => Navigator.pop(context),
        ),

        ElevatedButton(
          child: const Text("Save"),
          onPressed: () {
            widget.onSave(
              nameController.text.trim(),
              descController.text.trim(),
              double.tryParse(priceController.text.trim()) ?? 0.0,
              imageFile,
            );
          },
        ),
      ],
    );
  }
}
