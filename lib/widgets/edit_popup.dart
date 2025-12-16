import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/config.dart';

class EditProductPopup extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onSaved;
  const EditProductPopup({super.key, required this.product, this.onSaved});

  @override
  State<EditProductPopup> createState() => _EditProductPopupState();
}

class _EditProductPopupState extends State<EditProductPopup> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _offerPriceController = TextEditingController();
  final _quantityController = TextEditingController();

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> brands = [];
  List<Map<String, dynamic>> variantTypes = [];
  List<Map<String, dynamic>> variants = [];

  String? selectedCategoryId;
  String? selectedSubcategoryId;
  String? selectedBrandId;
  int? selectedVariantTypeId;
  int? selectedVariantId;

  final List<File?> _images = List<File?>.filled(5, null);
  final List<String?> _existingImageUrls = List<String?>.filled(5, null);
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    prefillData();
    fetchDependencies();
  }

  void prefillData() {
    final p = widget.product;
    _nameController.text = p['name'] ?? '';
    _descController.text = p['description'] ?? '';
    _priceController.text = (p['price'] ?? '').toString();
    _offerPriceController.text = (p['offer_price'] ?? '').toString();
    _quantityController.text = (p['quantity'] ?? 0).toString();

    selectedCategoryId = p['category_id']?.toString();
    selectedSubcategoryId = p['subcategory_id']?.toString();
    selectedBrandId = p['brand_id']?.toString();
    selectedVariantTypeId = p['variant_type_id'];
    selectedVariantId = p['variant_id'];

    _existingImageUrls[0] = p['main_image'];
    _existingImageUrls[1] = p['image2'];
    _existingImageUrls[2] = p['image3'];
    _existingImageUrls[3] = p['image4'];
    _existingImageUrls[4] = p['image5'];

    if (selectedVariantTypeId != null) fetchVariants(selectedVariantTypeId!);
  }

  Future<void> fetchDependencies() async {
    try {
      final catRes = await AppConfig.supabase
          .from('categories')
          .select()
          .order('name');
      final subRes = await AppConfig.supabase
          .from('subcategories')
          .select()
          .order('name');
      final brandRes = await AppConfig.supabase
          .from('brands')
          .select()
          .order('name');
      final variantTypeRes = await AppConfig.supabase
          .from('variant_types')
          .select()
          .order('name');

      setState(() {
        categories = List<Map<String, dynamic>>.from(catRes ?? []);
        subcategories = List<Map<String, dynamic>>.from(subRes ?? []);
        brands = List<Map<String, dynamic>>.from(brandRes ?? []);
        variantTypes = List<Map<String, dynamic>>.from(variantTypeRes ?? []);
      });
    } catch (e) {
      debugPrint("Dependencies fetch error: $e");
    }
  }

  Future<void> fetchVariants(int variantTypeId) async {
    try {
      final res = await AppConfig.supabase
          .from('variants')
          .select()
          .eq('variant_type_id', variantTypeId)
          .order('name');
      setState(() {
        variants = List<Map<String, dynamic>>.from(res ?? []);
        // Keep selectedVariantId if it exists in the new list
        if (!variants.any((v) => v['id'] == selectedVariantId)) {
          selectedVariantId = null;
        }
      });
    } catch (e) {
      debugPrint("Variants fetch error: $e");
    }
  }

  Future<void> pickImageAt(int index) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _images[index] = File(picked.path));
  }

  Future<String?> _uploadFile(File file) async {
    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}_${file.hashCode}.jpg';
    final bytes = await file.readAsBytes();
    await AppConfig.supabase.storage
        .from('product_images')
        .uploadBinary(fileName, bytes);
    return AppConfig.supabase.storage
        .from('product_images')
        .getPublicUrl(fileName);
  }

  Future<Map<String, String?>> uploadAllSelectedImages() async {
    final Map<String, String?> urls = {
      'main_image': _existingImageUrls[0],
      'image2': _existingImageUrls[1],
      'image3': _existingImageUrls[2],
      'image4': _existingImageUrls[3],
      'image5': _existingImageUrls[4],
    };

    for (int i = 0; i < _images.length; i++) {
      final f = _images[i];
      if (f != null) {
        final uploaded = await _uploadFile(f);
        if (uploaded == null) throw Exception('Image upload failed at $i');
        switch (i) {
          case 0:
            urls['main_image'] = uploaded;
            break;
          case 1:
            urls['image2'] = uploaded;
            break;
          case 2:
            urls['image3'] = uploaded;
            break;
          case 3:
            urls['image4'] = uploaded;
            break;
          case 4:
            urls['image5'] = uploaded;
            break;
        }
      }
    }
    return urls;
  }

  Future<void> updateProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        selectedCategoryId == null ||
        selectedSubcategoryId == null ||
        selectedBrandId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill the required fields")),
      );
      return;
    }

    setState(() => _loading = true);

    Map<String, String?> uploadedUrls = {};
    try {
      uploadedUrls = await uploadAllSelectedImages();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Image upload failed")));
      setState(() => _loading = false);
      return;
    }

    final updateData = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'offer_price': double.tryParse(_offerPriceController.text.trim()),
      'quantity': int.tryParse(_quantityController.text.trim()) ?? 0,
      'category_id': selectedCategoryId,
      'subcategory_id': selectedSubcategoryId,
      'brand_id': selectedBrandId,
      'variant_type_id': selectedVariantTypeId,
      'variant_id': selectedVariantId,
      ...uploadedUrls,
    };

    try {
      await AppConfig.supabase
          .from('products')
          .update(updateData)
          .eq('id', widget.product['id']);
      widget.onSaved?.call();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget imageTile(int index, String label) {
    final file = _images[index];
    final existingUrl = _existingImageUrls[index];

    return GestureDetector(
      onTap: () => pickImageAt(index),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
          image:
              file != null
                  ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                  : (existingUrl != null
                      ? DecorationImage(
                        image: NetworkImage(existingUrl),
                        fit: BoxFit.cover,
                      )
                      : null),
        ),
        child:
            file == null && existingUrl == null
                ? Center(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0f1113),
      title: const Text("Edit Product", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: imageTile(i, i == 0 ? "Main" : "Image ${i + 1}"),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCategoryId,
              items:
                  categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c['id'].toString(),
                          child: Text(c['name'] ?? '-'),
                        ),
                      )
                      .toList(),
              onChanged: (v) {
                setState(() {
                  selectedCategoryId = v;
                  selectedSubcategoryId = null;
                  selectedBrandId = null;
                });
              },
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSubcategoryId,
              items:
                  subcategories
                      .where(
                        (s) =>
                            s['category_id'].toString() == selectedCategoryId,
                      )
                      .map(
                        (s) => DropdownMenuItem(
                          value: s['id'].toString(),
                          child: Text(s['name'] ?? '-'),
                        ),
                      )
                      .toList(),
              onChanged: (v) {
                setState(() {
                  selectedSubcategoryId = v;
                  selectedBrandId = null;
                });
              },
              decoration: const InputDecoration(labelText: "Sub-category"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedBrandId,
              items:
                  brands
                      .where(
                        (b) =>
                            selectedSubcategoryId != null &&
                            b['sub_category_id'].toString() ==
                                selectedSubcategoryId,
                      )
                      .map(
                        (b) => DropdownMenuItem(
                          value: b['id'].toString(),
                          child: Text(b['name'] ?? '-'),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => selectedBrandId = v),
              decoration: const InputDecoration(labelText: "Brand"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: selectedVariantTypeId,
              items:
                  variantTypes
                      .map(
                        (v) => DropdownMenuItem<int>(
                          value: (v['id'] as int),
                          child: Text(v['name'] ?? '-'),
                        ),
                      )
                      .toList(),
              onChanged: (v) {
                if (v != null) fetchVariants(v);
                setState(() => selectedVariantTypeId = v);
              },
              decoration: const InputDecoration(labelText: "Variant Type"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: selectedVariantId,
              items:
                  variants
                      .map(
                        (v) => DropdownMenuItem<int>(
                          value: (v['id'] as int),
                          child: Text(v['name'] ?? '-'),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => selectedVariantId = v),
              decoration: const InputDecoration(labelText: "Variant"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _offerPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Offer Price (optional)",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            const SizedBox(height: 16),
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : updateProduct,
                  child:
                      _loading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text("Update"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
