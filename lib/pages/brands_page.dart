import 'package:admin_panel/widgets/edit_brand_popup.dart';
import 'package:flutter/material.dart';
import '../core/config.dart';
import '../widgets/delete_button.dart';
import '../widgets/edit_button.dart';
import '../components/add_brand_popup.dart';

class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  List<Map<String, dynamic>> brands = [];
  List<Map<String, dynamic>> subcategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    try {
      final brandRes = await AppConfig.supabase
          .from('brands')
          .select('id, name, status, logo_url, sub_category_id, created_at')
          .order('created_at', ascending: false);

      final subcatRes = await AppConfig.supabase
          .from('subcategories')
          .select('id, name');

      brands = List<Map<String, dynamic>>.from(brandRes);
      subcategories = List<Map<String, dynamic>>.from(subcatRes);
    } catch (e) {
      debugPrint("Error loading brands: $e");
    }

    setState(() => isLoading = false);
  }

  void showAddBrandPopup() {
    showDialog(
      context: context,
      builder:
          (_) => AddBrandPopup(
            subcategories: subcategories,
            onSave: () {
              Navigator.pop(context);
              loadInitialData();
            },
          ),
    );
  }

  void showEditBrandPopup(Map<String, dynamic> brand) {
    showDialog(
      context: context,
      builder:
          (_) => EditBrandPopup(
            brand: brand,
            subcategories: subcategories,
            onSave: () {
              Navigator.pop(context);
              loadInitialData();
            },
          ),
    );
  }

  Future<void> deleteBrand(String uuid) async {
    try {
      await AppConfig.supabase.from('brands').delete().eq('id', uuid);
      loadInitialData();
    } catch (e) {
      debugPrint("Error deleting brand: $e");
    }
  }

  String formatDate(String? isoString) {
    if (isoString == null) return "—";
    try {
      final d = DateTime.parse(isoString).toLocal();
      return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
          "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoString;
    }
  }

  String getSubCatName(String id) {
    final sub = subcategories.firstWhere(
      (e) => e['id'] == id,
      orElse: () => {'name': 'Unknown'},
    );
    return sub['name'];
  }

  Widget buildBrandCard(Map<String, dynamic> brand) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          // NAME
          Expanded(
            flex: 2,
            child: Text(
              brand['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // SUBCATEGORY
          Expanded(
            flex: 2,
            child: Text(
              getSubCatName(brand['sub_category_id']),
              style: const TextStyle(color: Colors.white70),
            ),
          ),

          // STATUS
          Expanded(
            child: Text(
              brand['status'] ? "Active" : "Inactive",
              style: TextStyle(
                color: brand['status'] ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
          ),

          // DATE
          Expanded(
            flex: 2,
            child: Text(
              formatDate(brand['created_at']),
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ),

          EditButton(onTap: () => showEditBrandPopup(brand)),

          DeleteButton(
            onConfirm: () async {
              await deleteBrand(brand['id']); // UUID delete
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f12),
      appBar: AppBar(
        title: const Text("Brands"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: showAddBrandPopup,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : brands.isEmpty
                ? const Center(
                  child: Text(
                    "No brands found",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                : ListView.builder(
                  itemCount: brands.length,
                  itemBuilder: (_, i) => buildBrandCard(brands[i]),
                ),
      ),
    );
  }
}
