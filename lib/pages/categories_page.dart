import 'package:admin_panel/components/addcategory_page.dart';
import 'package:flutter/material.dart';
import '../core/config.dart';
import '../widgets/edit_category_popup.dart';
import '../widgets/delete_button.dart';
import '../widgets/edit_button.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() => isLoading = true);
    try {
      final response = await AppConfig.supabase
          .from('categories')
          .select()
          .order('created_at', ascending: false);

      categories = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      categories = [];
    }
    setState(() => isLoading = false);
  }

  void showAddPopup() {
    showDialog(
      context: context,
      builder:
          (_) => AddCategoryPopup(
            onSave: (name) async {
              if (name.isEmpty) return;

              await AppConfig.supabase.from('categories').insert({
                'name': name,
                'created_at': DateTime.now().toIso8601String(),
              });

              Navigator.pop(context);
              fetchCategories();
            },
          ),
    );
  }

  void showEditPopup(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder:
          (_) => EditCategoryPopup(
            category: category,
            onSave: () async {
              fetchCategories();
            },
          ),
    );
  }

  Future<void> deleteCategory(String id) async {
    try {
      await AppConfig.supabase.from('categories').delete().eq('id', id);
      fetchCategories();
    } catch (e) {
      debugPrint("Error deleting category: $e");
    }
  }

  String formatDate(String? isoString) {
    if (isoString == null) return "—";
    try {
      final date = DateTime.parse(isoString).toLocal();
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoString;
    }
  }

  Widget buildCategoryCard(Map<String, dynamic> cat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            flex: 3,
            child: Text(
              cat['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // TIMESTAMP
          Expanded(
            flex: 3,
            child: Text(
              formatDate(cat['created_at']),
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ),

          // EDIT BUTTON
          EditButton(onTap: () => showEditPopup(cat)),

          // DELETE BUTTON
          DeleteButton(
            onConfirm: () async {
              await deleteCategory(cat['id']); // cat['id'] is a String UUID
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
        title: const Text('Categories'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: showAddPopup,
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
                : categories.isEmpty
                ? const Center(
                  child: Text(
                    "No categories found",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder:
                      (context, index) => buildCategoryCard(categories[index]),
                ),
      ),
    );
  }
}
