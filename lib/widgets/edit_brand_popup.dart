import 'package:flutter/material.dart';
import '../core/config.dart';

class EditBrandPopup extends StatefulWidget {
  final Map<String, dynamic> brand;
  final List<Map<String, dynamic>> subcategories;
  final VoidCallback onSave;

  const EditBrandPopup({
    super.key,
    required this.brand,
    required this.subcategories,
    required this.onSave,
  });

  @override
  State<EditBrandPopup> createState() => _EditBrandPopupState();
}

class _EditBrandPopupState extends State<EditBrandPopup> {
  late TextEditingController nameController;
  late TextEditingController logoController;

  String? selectedSubCat;
  bool status = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.brand['name']);
    logoController = TextEditingController(text: widget.brand['logo_url']);
    selectedSubCat = widget.brand['sub_category_id'];
    status = widget.brand['status'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF181A1F),
      title: const Text("Edit Brand", style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Brand Name",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedSubCat,
              items:
                  widget.subcategories
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e['id'] as String,
                          child: Text(
                            e['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
              dropdownColor: Colors.black,
              decoration: const InputDecoration(
                labelText: "Select Sub Category",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: (v) => setState(() => selectedSubCat = v),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Active", style: TextStyle(color: Colors.white)),
                Switch(
                  value: status,
                  onChanged: (v) => setState(() => status = v),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              controller: logoController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Logo URL (optional)",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () async {
            await AppConfig.supabase
                .from('brands')
                .update({
                  'name': nameController.text.trim(),
                  'logo_url': logoController.text.trim(),
                  'status': status,
                  'sub_category_id': selectedSubCat,
                })
                .eq('id', widget.brand['id']); // UUID update

            widget.onSave();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
