import 'package:admin_panel/components/add_variant_popup.dart';
import 'package:admin_panel/widgets/add_button.dart';
import 'package:admin_panel/widgets/edit_variant_popup.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel/core/config.dart';

class VariantsPage extends StatefulWidget {
  const VariantsPage({super.key});

  @override
  State<VariantsPage> createState() => _VariantsPageState();
}

class _VariantsPageState extends State<VariantsPage> {
  List<dynamic> variants = [];
  List<dynamic> variantTypes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchVariants();
  }

  Future<void> fetchVariants() async {
    try {
      setState(() => isLoading = true);

      final typesRes = await AppConfig.supabase
          .from("variant_types")
          .select()
          .order("name", ascending: true);

      final variantsRes = await AppConfig.supabase
          .from("variants")
          .select("*, variant_types(name)")
          .order("id", ascending: true);

      if (typesRes is List) variantTypes = typesRes;
      if (variantsRes is List) variants = variantsRes;
    } catch (e) {
      debugPrint("Error fetching variants: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteVariant(int id) async {
    try {
      await AppConfig.supabase.from("variants").delete().eq("id", id);
      fetchVariants();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void openAddPopup() {
    showDialog(
      context: context,
      builder:
          (context) => AddVariantPopup(
            variantTypes: variantTypes,
            onSaved: fetchVariants,
          ),
    );
  }

  void openEditPopup(Map item) {
    showDialog(
      context: context,
      builder:
          (context) => EditVariantPopup(
            data: item,
            variantTypes: variantTypes,
            onSaved: fetchVariants,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Variants",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AddButton(label: "Add Variant", onPressed: openAddPopup),
            ],
          ),
          const SizedBox(height: 20),

          // TABLE HEADER
          Card(
            color: Colors.grey.shade800,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Variant Type",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Created At",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Actions",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // LIST
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : variants.isEmpty
                    ? const Center(
                      child: Text(
                        "No variants found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : ListView.builder(
                      itemCount: variants.length,
                      itemBuilder: (context, index) {
                        final variant = variants[index];
                        final rowColor =
                            index % 2 == 0
                                ? Colors.grey.shade900
                                : Colors.grey.shade800;

                        return Card(
                          color: rowColor,
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    variant['name'] ?? '',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    variant['variant_types']?['name'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            variant['status'] == true
                                                ? Colors.green
                                                : Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        variant['status'] == true
                                            ? "Active"
                                            : "Inactive",
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    variant['created_at']?.toString().substring(
                                          0,
                                          19,
                                        ) ??
                                        '',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: () => openEditPopup(variant),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed:
                                            () => deleteVariant(variant['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
