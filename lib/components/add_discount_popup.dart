import 'package:flutter/material.dart';
import 'package:admin_panel/core/config.dart';

class AddDiscountPopup extends StatefulWidget {
  final VoidCallback onSaved;

  const AddDiscountPopup({super.key, required this.onSaved});

  @override
  State<AddDiscountPopup> createState() => _AddDiscountPopupState();
}

class _AddDiscountPopupState extends State<AddDiscountPopup> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController valueCtrl = TextEditingController();

  String appliesTo = "all";
  String discountType = "percentage";
  bool status = true;

  String? selectedCategory;
  String? selectedProduct;

  DateTime? startDate;
  DateTime? endDate;

  List<dynamic> categories = [];
  List<dynamic> products = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final c = await AppConfig.supabase.from("categories").select();
      final p = await AppConfig.supabase.from("products").select();

      debugPrint("Fetched categories: $c");
      debugPrint("Fetched products: $p");

      setState(() {
        categories = c;
        products = p;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching categories/products: $e")),
      );
    }
  }

  Future<void> pickDate(bool isStart) async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          startDate = picked;
        else
          endDate = picked;
      });
    }
  }

  Future<void> saveDiscount() async {
    if (nameCtrl.text.isEmpty ||
        valueCtrl.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (appliesTo == "category" &&
        (selectedCategory == null || selectedCategory!.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a category")));
      return;
    }

    if (appliesTo == "product" &&
        (selectedProduct == null || selectedProduct!.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a product")));
      return;
    }

    setState(() => loading = true);

    try {
      await AppConfig.supabase.from("discounts").insert({
        "name": nameCtrl.text.trim(),
        "discount_type": discountType,
        "discount_value": double.tryParse(valueCtrl.text) ?? 0,
        "applies_to": appliesTo,
        "category_id": appliesTo == "category" ? selectedCategory : null,
        "product_id": appliesTo == "product" ? selectedProduct : null,
        "start_date": startDate!.toIso8601String(),
        "end_date": endDate!.toIso8601String(),
        "status": status,
      });

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Save discount error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Discount",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Name
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Discount Name",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 15),

              // Discount Type
              DropdownButtonFormField<String>(
                value: discountType,
                items: const [
                  DropdownMenuItem(
                    value: "percentage",
                    child: Text("Percentage (%)"),
                  ),
                  DropdownMenuItem(value: "fixed", child: Text("Fixed Amount")),
                ],
                dropdownColor: Colors.grey[900],
                onChanged:
                    (v) => setState(() => discountType = v ?? "percentage"),
                decoration: const InputDecoration(
                  labelText: "Discount Type",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 15),

              // Value
              TextField(
                controller: valueCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Value",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 15),

              // Applies To
              DropdownButtonFormField<String>(
                value: appliesTo,
                items: const [
                  DropdownMenuItem(value: "all", child: Text("All Products")),
                  DropdownMenuItem(value: "category", child: Text("Category")),
                  DropdownMenuItem(
                    value: "product",
                    child: Text("Specific Product"),
                  ),
                ],
                dropdownColor: Colors.grey[900],
                onChanged: (v) {
                  setState(() {
                    appliesTo = v ?? "all";
                    selectedCategory = null;
                    selectedProduct = null;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Applies To",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 15),

              // Category Dropdown
              if (appliesTo == "category")
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items:
                      categories.map<DropdownMenuItem<String>>((c) {
                        final id = c['id']?.toString() ?? '';
                        final name = c['name'] ?? 'Unnamed Category';
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                  onChanged: (v) => setState(() => selectedCategory = v),
                  dropdownColor: Colors.grey[900],
                  hint: const Text(
                    "Select a category",
                    style: TextStyle(color: Colors.white70),
                  ),
                  decoration: const InputDecoration(
                    labelText: "Category",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),

              // Product Dropdown
              if (appliesTo == "product")
                DropdownButtonFormField<String>(
                  value: selectedProduct,
                  items:
                      products.map<DropdownMenuItem<String>>((p) {
                        final id = p['id']?.toString() ?? '';
                        final name = p['name'] ?? 'Unnamed Product';
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                  onChanged: (v) => setState(() => selectedProduct = v),
                  dropdownColor: Colors.grey[900],
                  hint: const Text(
                    "Select a product",
                    style: TextStyle(color: Colors.white70),
                  ),
                  decoration: const InputDecoration(
                    labelText: "Product",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              const SizedBox(height: 20),

              // Date Pickers
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => pickDate(true),
                      child: Text(
                        startDate == null
                            ? "Start Date"
                            : startDate!.toString().substring(0, 10),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => pickDate(false),
                      child: Text(
                        endDate == null
                            ? "End Date"
                            : endDate!.toString().substring(0, 10),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status
              Row(
                children: [
                  const Text("Status: ", style: TextStyle(color: Colors.white)),
                  Switch(
                    value: status,
                    onChanged: (v) => setState(() => status = v),
                    activeThumbColor: Colors.green,
                  ),
                  Text(
                    status ? "Active" : "Inactive",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: loading ? null : saveDiscount,
                    child:
                        loading
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
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
