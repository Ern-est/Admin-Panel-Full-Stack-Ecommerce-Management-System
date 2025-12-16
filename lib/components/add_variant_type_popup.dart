import 'package:flutter/material.dart';
import 'package:admin_panel/core/config.dart';

class AddVariantTypePopup extends StatefulWidget {
  final VoidCallback onSaved;

  const AddVariantTypePopup({super.key, required this.onSaved});

  @override
  State<AddVariantTypePopup> createState() => _AddVariantTypePopupState();
}

class _AddVariantTypePopupState extends State<AddVariantTypePopup> {
  final TextEditingController nameController = TextEditingController();
  bool status = true; // default active
  bool loading = false;

  Future<void> saveVariantType() async {
    if (nameController.text.trim().isEmpty) return;

    try {
      setState(() => loading = true);

      await AppConfig.supabase.from("variant_types").insert({
        "name": nameController.text.trim(),
        "status": status,
      });

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error inserting variant type: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1b1b1f),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Variant Type",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // NAME FIELD
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Variant Type Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // STATUS SWITCH
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Status"),
                  Switch(
                    value: status,
                    onChanged: (val) => setState(() => status = val),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: loading ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: loading ? null : saveVariantType,
                    child:
                        loading
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
