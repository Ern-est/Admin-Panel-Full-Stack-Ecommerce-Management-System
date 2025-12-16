import 'package:flutter/material.dart';
import 'package:admin_panel/core/config.dart';

class EditVariantTypePopup extends StatefulWidget {
  final Map data;
  final VoidCallback onSaved;

  const EditVariantTypePopup({
    super.key,
    required this.data,
    required this.onSaved,
  });

  @override
  State<EditVariantTypePopup> createState() => _EditVariantTypePopupState();
}

class _EditVariantTypePopupState extends State<EditVariantTypePopup> {
  late TextEditingController nameController;
  bool status = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.data["name"] ?? "");
    status = widget.data["status"] == true;
  }

  Future<void> updateVariantType() async {
    final id = widget.data["id"];

    if (nameController.text.trim().isEmpty) return;

    try {
      setState(() => loading = true);

      await AppConfig.supabase
          .from("variant_types")
          .update({"name": nameController.text.trim(), "status": status})
          .eq("id", id);

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error updating variant type: $e");
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
                "Edit Variant Type",
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
                    onChanged: (v) => setState(() => status = v),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: loading ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: loading ? null : updateVariantType,
                    child:
                        loading
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text("Update"),
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
