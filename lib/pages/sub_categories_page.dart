import 'package:admin_panel/components/add_subcategory_popup.dart';
import 'package:flutter/material.dart';
import '../core/config.dart';
import '../widgets/add_button.dart';
import 'package:intl/intl.dart';
import '../widgets/edit_subcategory_popup.dart';

class SubCategoriesPage extends StatefulWidget {
  const SubCategoriesPage({super.key});

  @override
  State<SubCategoriesPage> createState() => _SubCategoriesPageState();
}

class _SubCategoriesPageState extends State<SubCategoriesPage> {
  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    setState(() => isLoading = true);

    try {
      final catRes = await AppConfig.supabase
          .from('categories')
          .select()
          .order('name');

      final subRes = await AppConfig.supabase
          .from('subcategories')
          .select('*, categories(name)')
          .order('created_at', ascending: false);

      if (catRes is List) categories = List<Map<String, dynamic>>.from(catRes);
      if (subRes is List) {
        subcategories = List<Map<String, dynamic>>.from(subRes);
      }
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
    }

    setState(() => isLoading = false);
  }

  void showAddPopup() {
    showDialog(
      context: context,
      builder:
          (_) => AddSubCategoryPopup(
            categories: categories,
            onSave: (name, categoryId) async {
              await AppConfig.supabase.from('subcategories').insert({
                'name': name,
                'category_id': categoryId,
                'created_at': DateTime.now().toIso8601String(),
              });

              Navigator.pop(context);
              fetchAllData();
            },
          ),
    );
  }

  void showEditPopup(Map<String, dynamic> subcat) {
    showDialog(
      context: context,
      builder:
          (_) => EditSubCategoryPopup(
            subcategory: subcat,
            categories: categories,
            onSave: () async => await fetchAllData(),
          ),
    );
  }

  Future<void> deleteSubCategory(String id) async {
    try {
      await AppConfig.supabase.from('subcategories').delete().eq('id', id);
      fetchAllData();
    } catch (e) {
      debugPrint('Error deleting subcategory: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sub-Categories"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AddButton(label: "Add", onPressed: showAddPopup),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // HEADER ROW
                    Card(
                      color: Colors.deepOrange,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Sub-Category",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Category",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Created At",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Actions",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // LIST
                    subcategories.isEmpty
                        ? const Expanded(
                          child: Center(
                            child: Text(
                              "No sub-categories found",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        )
                        : Expanded(
                          child: ListView.builder(
                            itemCount: subcategories.length,
                            itemBuilder: (context, index) {
                              final sc = subcategories[index];
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
                                      // Sub-Category Name
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          sc['name'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Category Name
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          sc['categories']['name'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      // Timestamp
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          DateFormat("MMM d, yyyy").format(
                                            DateTime.parse(sc['created_at']),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ),
                                      // Action Buttons
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blueAccent,
                                              ),
                                              onPressed:
                                                  () => showEditPopup(sc),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed:
                                                  () => deleteSubCategory(
                                                    sc['id'] as String,
                                                  ),
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
              ),
    );
  }
}
