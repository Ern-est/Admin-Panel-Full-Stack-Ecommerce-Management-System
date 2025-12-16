import 'package:flutter/material.dart';
import '../models/rating.dart';
import '../services/ratings_service.dart';

class RatingsPage extends StatefulWidget {
  const RatingsPage({super.key});

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  bool loading = true;
  List<Rating> ratings = [];

  @override
  void initState() {
    super.initState();
    loadRatings();
  }

  Future<void> loadRatings() async {
    setState(() => loading = true);
    ratings = await RatingsService.fetchRatings();
    setState(() => loading = false);
  }

  Widget buildStars(int count) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < count ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        title: const Text('Ratings'),
        backgroundColor: Colors.grey[900],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : ratings.isEmpty
              ? const Center(
                child: Text(
                  'No ratings yet',
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : RefreshIndicator(
                onRefresh: loadRatings,
                child: ListView.builder(
                  itemCount: ratings.length,
                  itemBuilder: (_, i) {
                    final r = ratings[i];
                    return Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: buildStars(r.rating),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Client: ${r.clientName ?? "Unknown"}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Staff: ${r.staffName ?? "N/A"}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            if (r.comment != null)
                              Text(
                                r.comment!,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              '${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}-${r.createdAt.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
