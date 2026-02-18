import 'package:admin_panel/controllers/ratings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/rating.dart';

class RatingsPage extends StatefulWidget {
  const RatingsPage({super.key});

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<RatingsProvider>();
    // Load initial ratings
    Future.microtask(() => provider.loadRatings());
  }

  Widget buildStars(int count) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < count ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RatingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        title: const Text('Ratings'),
        backgroundColor: Colors.grey[900],
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.ratings.isEmpty
              ? const Center(
                child: Text(
                  'No ratings yet',
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : RefreshIndicator(
                onRefresh: provider.loadRatings,
                child: ListView.builder(
                  itemCount: provider.ratings.length,
                  itemBuilder: (_, i) {
                    final Rating r = provider.ratings[i];

                    return Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildStars(r.rating),
                            if (r.verified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Verified",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              "Product: ${r.productName ?? "Unknown"}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Client: ${r.clientName ?? "Unknown"}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            if (r.comment != null && r.comment!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  r.comment!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              "${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}-${r.createdAt.day.toString().padLeft(2, '0')}",
                              style: const TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text("Delete Rating?"),
                                    content: const Text(
                                      "This action cannot be undone.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await provider.deleteRating(r.id);
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
