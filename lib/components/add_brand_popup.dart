import 'package:flutter/material.dart';
import '../core/config.dart';

class AddBrandPopup extends StatefulWidget {
  final List<Map<String, dynamic>> subcategories;
  final VoidCallback onSave;

  const AddBrandPopup({
    super.key,
    required this.subcategories,
    required this.onSave,
  });

  @override
  State<AddBrandPopup> createState() => _AddBrandPopupState();
}

class _AddBrandPopupState extends State<AddBrandPopup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController logoController = TextEditingController();

  String? selectedSubCat;
  bool status = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF181A1F),
      title: const Text("Add Brand", style: TextStyle(color: Colors.white)),
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

            // SUBCATEGORY DROPDOWN
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

            // STATUS SWITCH
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
            if (nameController.text.trim().isEmpty || selectedSubCat == null) {
              return;
            }

            await AppConfig.supabase.from('brands').insert({
              'name': nameController.text.trim(),
              'logo_url': logoController.text.trim(),
              'sub_category_id': selectedSubCat,
              'status': status,
              'created_at': DateTime.now().toIso8601String(),
            });

            widget.onSave();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
