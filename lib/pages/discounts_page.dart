import 'package:admin_panel/components/add_discount_popup.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel/core/config.dart';
import 'package:admin_panel/widgets/add_button.dart';
import 'package:admin_panel/widgets/edit_discount_popup.dart';

class DiscountsPage extends StatefulWidget {
  const DiscountsPage({super.key});

  @override
  State<DiscountsPage> createState() => _DiscountsPageState();
}

class _DiscountsPageState extends State<DiscountsPage> {
  List<dynamic> discounts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDiscounts();
  }

  Future<void> fetchDiscounts() async {
    try {
      setState(() => isLoading = true);

      final res = await AppConfig.supabase
          .from("discounts")
          .select("""
            *,
            categories:category_id(name),
            products:product_id(name)
          """)
          .order("created_at", ascending: true);

      setState(() => discounts = res);
    } catch (e) {
      debugPrint("Error fetching discounts: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteDiscount(String id) async {
    try {
      await AppConfig.supabase.from("discounts").delete().eq("id", id);
      fetchDiscounts();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void openAddPopup() {
    showDialog(
      context: context,
      builder: (_) => AddDiscountPopup(onSaved: fetchDiscounts),
    );
  }

  void openEditPopup(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder:
          (_) => EditDiscountPopup(discountData: item, onSaved: fetchDiscounts),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Discounts",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AddButton(label: "Add Discount", onPressed: openAddPopup),
            ],
          ),
          const SizedBox(height: 20),

          // List
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : discounts.isEmpty
                    ? const Center(
                      child: Text(
                        "No discounts found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children:
                            discounts.map((d) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    // Name
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        d["name"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Applies To
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        d["applies_to"] == "all"
                                            ? "All Products"
                                            : d["applies_to"] == "category"
                                            ? "Category: ${d["categories"]?["name"] ?? "-"}"
                                            : "Product: ${d["products"]?["name"] ?? "-"}",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    // Type
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "${d["discount_type"]} (${d["discount_value"]})",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    // Status
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                d["status"] == true
                                                    ? Colors.green
                                                    : Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            d["status"] ? "Active" : "Inactive",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Date Range
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "${d["start_date"].toString().substring(0, 10)} → ${d["end_date"].toString().substring(0, 10)}",
                                        style: const TextStyle(
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ),
                                    // Edit
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () => openEditPopup(d),
                                    ),
                                    // Delete
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => deleteDiscount(d["id"]),
                                    ),
                                  ],
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
