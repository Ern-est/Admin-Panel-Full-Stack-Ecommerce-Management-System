import '../core/config.dart';
import '../models/rating.dart';
import 'package:flutter/foundation.dart';

class RatingsService {
  /// Fetch all ratings (admin view)
  static Future<List<Rating>> fetchRatings() async {
    try {
      final res = await AppConfig.supabase
          .from('ratings')
          .select('''
            id,
            rating,
            comment,
            created_at,
            order_id,
            clients(name),
            staff:users(full_name,email)
          ''')
          .order('created_at', ascending: false);

      if (res == null) return [];

      return (res as List)
          .map((e) => Rating.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Fetch ratings error: $e');
      return [];
    }
  }
}
