import 'package:flutter/material.dart';
import 'package:admin_panel/core/config.dart';

class EditDiscountPopup extends StatefulWidget {
  final Map<String, dynamic> discountData;
  final VoidCallback onSaved;

  const EditDiscountPopup({
    super.key,
    required this.discountData,
    required this.onSaved,
  });

  @override
  State<EditDiscountPopup> createState() => _EditDiscountPopupState();
}

class _EditDiscountPopupState extends State<EditDiscountPopup> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController valueCtrl = TextEditingController();

  String appliesTo = "all"; // all / category / product
  String discountType = "percentage"; // percentage / fixed
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
    initData();
  }

  Future<void> initData() async {
    // Load dropdown data first
    final c = await AppConfig.supabase.from("categories").select();
    final p = await AppConfig.supabase.from("products").select();

    setState(() {
      categories = c;
      products = p;
    });

    // Prefill fields AFTER loading lists
    final d = widget.discountData;
    nameCtrl.text = d["name"] ?? "";
    valueCtrl.text = (d["discount_value"] ?? "").toString();
    discountType = d["discount_type"] ?? "percentage";
    appliesTo = d["applies_to"] ?? "all";
    status = d["status"] ?? true;
    startDate =
        d["start_date"] != null ? DateTime.parse(d["start_date"]) : null;
    endDate = d["end_date"] != null ? DateTime.parse(d["end_date"]) : null;

    // IDs as String
    selectedCategory = d["category_id"]?.toString();
    selectedProduct = d["product_id"]?.toString();
    setState(() {});
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

    // Validation
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
      await AppConfig.supabase
          .from("discounts")
          .update({
            "name": nameCtrl.text.trim(),
            "discount_type": discountType,
            "discount_value": double.tryParse(valueCtrl.text) ?? 0,
            "applies_to": appliesTo,
            "category_id": appliesTo == "category" ? selectedCategory : null,
            "product_id": appliesTo == "product" ? selectedProduct : null,
            "start_date": startDate!.toIso8601String(),
            "end_date": endDate!.toIso8601String(),
            "status": status,
          })
          .eq("id", widget.discountData["id"]);

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Update discount error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
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
                "Edit Discount",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                onChanged: (v) => setState(() => appliesTo = v ?? "all"),
                decoration: const InputDecoration(
                  labelText: "Applies To",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 15),

              // Category / Product dropdown
              if (appliesTo == "category")
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items:
                      categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c["id"].toString(),
                              child: Text(c["name"]),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v),
                  dropdownColor: Colors.grey[900],
                  decoration: const InputDecoration(
                    labelText: "Category",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              if (appliesTo == "product")
                DropdownButtonFormField<String>(
                  value: selectedProduct,
                  items:
                      products
                          .map(
                            (p) => DropdownMenuItem(
                              value: p["id"].toString(),
                              child: Text(p["name"]),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => selectedProduct = v),
                  dropdownColor: Colors.grey[900],
                  decoration: const InputDecoration(
                    labelText: "Product",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),

              const SizedBox(height: 20),

              // Date pickers
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
