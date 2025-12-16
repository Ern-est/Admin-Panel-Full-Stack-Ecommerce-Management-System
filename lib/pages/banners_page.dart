import 'package:admin_panel/components/add_banner_popup.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel/widgets/edit_banner_popup.dart';
import 'package:admin_panel/widgets/add_button.dart';
import 'package:admin_panel/core/config.dart';

class BannersPage extends StatefulWidget {
  const BannersPage({super.key});

  @override
  State<BannersPage> createState() => _BannersPageState();
}

class _BannersPageState extends State<BannersPage> {
  List<dynamic> banners = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    try {
      setState(() => isLoading = true);

      final res = await AppConfig.supabase
          .from('banners')
          .select()
          .order('id', ascending: true);

      setState(() => banners = res);
    } catch (e) {
      debugPrint("Error fetching banners: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteBanner(int id) async {
    try {
      await AppConfig.supabase.from('banners').delete().eq('id', id);
      fetchBanners();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void openAddPopup() {
    showDialog(
      context: context,
      builder: (_) => AddBannerPopup(onSaved: fetchBanners),
    );
  }

  void openEditPopup(Map<String, dynamic> banner) {
    showDialog(
      context: context,
      builder:
          (_) => EditBannerPopup(bannerData: banner, onSaved: fetchBanners),
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
                "Banners",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AddButton(label: "Add Banner", onPressed: openAddPopup),
            ],
          ),
          const SizedBox(height: 20),

          // TABLE HEADERS
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Image",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Title",
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
                    "Edit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // MAIN LIST
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : banners.isEmpty
                    ? const Center(
                      child: Text(
                        "No banners found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children:
                            banners.map((banner) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    // Banner Image - leading, fixed square
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          banner['image_url'] != null
                                              ? Image.network(
                                                banner['image_url'],
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              )
                                              : Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[800],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                    ),

                                    const SizedBox(
                                      width: 36,
                                    ), // spacing after image
                                    // Title
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        banner['title'] ?? "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    // Created At
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        banner['created_at']
                                                ?.toString()
                                                .substring(0, 19) ??
                                            "",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),

                                    // Edit Button
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: () => openEditPopup(banner),
                                      ),
                                    ),

                                    // Delete Button
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed:
                                            () => deleteBanner(banner['id']),
                                      ),
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
