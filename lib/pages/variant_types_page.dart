import 'package:admin_panel/components/add_variant_type_popup.dart';
import 'package:admin_panel/widgets/add_button.dart';
import 'package:admin_panel/widgets/edit_variant_type_popup.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel/core/config.dart';

class VariantTypesPage extends StatefulWidget {
  const VariantTypesPage({super.key});

  @override
  State<VariantTypesPage> createState() => _VariantTypesPageState();
}

class _VariantTypesPageState extends State<VariantTypesPage> {
  List<dynamic> variantTypes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchVariantTypes();
  }

  Future<void> fetchVariantTypes() async {
    try {
      setState(() => isLoading = true);

      final res = await AppConfig.supabase
          .from("variant_types")
          .select()
          .order("id", ascending: true);

      setState(() {
        variantTypes = res;
      });
    } catch (e) {
      debugPrint("Error fetching variant types: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteVariantType(int id) async {
    try {
      await AppConfig.supabase.from("variant_types").delete().eq("id", id);
      fetchVariantTypes();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void openAddPopup() {
    showDialog(
      context: context,
      builder: (context) => AddVariantTypePopup(onSaved: fetchVariantTypes),
    );
  }

  void openEditPopup(Map item) {
    showDialog(
      context: context,
      builder:
          (context) =>
              EditVariantTypePopup(data: item, onSaved: fetchVariantTypes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Variant Types",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AddButton(label: "Add Variant Type", onPressed: openAddPopup),
            ],
          ),
          const SizedBox(height: 20),

          // DATA
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : variantTypes.isEmpty
                    ? const Center(
                      child: Text(
                        "No variant types found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children:
                            variantTypes.map((item) {
                              return Card(
                                color: Colors.grey.shade900,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item["name"] ?? "",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item["created_at"]
                                                  ?.toString()
                                                  .substring(0, 19) ??
                                              "",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  item["status"] == true
                                                      ? Colors.green
                                                      : Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item["status"] == true
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
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blueAccent,
                                          ),
                                          onPressed: () => openEditPopup(item),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed:
                                              () =>
                                                  deleteVariantType(item["id"]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
