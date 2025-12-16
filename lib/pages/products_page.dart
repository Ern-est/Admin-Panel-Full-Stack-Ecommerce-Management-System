import 'package:flutter/material.dart';
import 'package:admin_panel/components/AddProductPage.dart';
import 'package:admin_panel/widgets/add_button.dart';
import 'package:admin_panel/widgets/edit_button.dart';
import 'package:admin_panel/widgets/delete_button.dart';
import 'package:admin_panel/widgets/edit_popup.dart';
import 'package:admin_panel/widgets/refresh_button.dart';
import '../core/config.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  Map<String, String> categoryNames = {};
  Map<String, String> subcategoryNames = {};
  Map<String, String> brandNames = {};
  Map<int, String> variantTypeNames = {};
  Map<int, String> variantNames = {};

  @override
  void initState() {
    super.initState();
    fetchDependencies();
    fetchProducts();
  }

  Future<void> fetchDependencies() async {
    try {
      final catRes = await AppConfig.supabase
          .from('categories')
          .select('id,name');
      final subRes = await AppConfig.supabase
          .from('subcategories')
          .select('id,name');
      final brandRes = await AppConfig.supabase
          .from('brands')
          .select('id,name');
      final variantTypeRes = await AppConfig.supabase
          .from('variant_types')
          .select('id,name');
      final variantRes = await AppConfig.supabase
          .from('variants')
          .select('id,name');

      categoryNames = {
        for (var c in catRes) c['id'].toString(): c['name'] ?? '-',
      };
      subcategoryNames = {
        for (var s in subRes) s['id'].toString(): s['name'] ?? '-',
      };
      brandNames = {
        for (var b in brandRes) b['id'].toString(): b['name'] ?? '-',
      };
      variantTypeNames = {
        for (var v in variantTypeRes) v['id'] as int: v['name'] ?? '-',
      };
      variantNames = {
        for (var v in variantRes) v['id'] as int: v['name'] ?? '-',
      };

      setState(() {});
    } catch (e) {
      debugPrint("Dependency fetch error: $e");
    }
  }

  Future<void> fetchProducts() async {
    if (mounted) setState(() => isLoading = true);
    try {
      final res = await AppConfig.supabase
          .from('products')
          .select('''
          id,
          name,
          description,
          price,
          offer_price,
          quantity,
          category_id,
          subcategory_id,
          brand_id,
          variant_type_id,
          variant_id,
          main_image,
          image2,
          image3,
          image4,
          image5
        ''')
          .order('created_at', ascending: false);

      products = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Error fetching products: $e');
      products = [];
    }
    if (mounted) setState(() => isLoading = false);
  }

  void showAddProductPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddProductPopup(onSaved: fetchProducts),
    );
  }

  Future<void> deleteProduct(String id) async {
    try {
      await AppConfig.supabase.from('products').delete().eq('id', id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Product deleted")));
      fetchProducts();
    } catch (e) {
      debugPrint("Delete error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          RefreshButton(onRefresh: fetchProducts),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AddButton(label: 'Add', onPressed: showAddProductPopup),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    products.isEmpty
                        ? const Center(
                          child: Text(
                            "No products found",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                        : Column(
                          children: [
                            // Header row
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: const [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Product Name',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Category',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Sub-category',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Brand',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Price',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Actions',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: Colors.white24),
                            Expanded(
                              child: ListView.separated(
                                itemCount: products.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final p = products[index];
                                  final name = p['name'] ?? '';
                                  final price =
                                      p['price']?.toString() ?? '0.00';
                                  final categoryName =
                                      categoryNames[p['category_id']] ?? '-';
                                  final subcategoryName =
                                      subcategoryNames[p['subcategory_id']] ??
                                      '-';
                                  final brandName =
                                      brandNames[p['brand_id']] ?? '-';
                                  return Card(
                                    color: Colors.grey.shade900,
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              categoryName,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              subcategoryName,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              brandName,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "\$${price}",
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                          EditButton(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (_) => EditProductPopup(
                                                      product: p,
                                                      onSaved: fetchProducts,
                                                    ),
                                              );
                                            },
                                          ),
                                          DeleteButton(
                                            onConfirm:
                                                () => deleteProduct(p['id']),
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
