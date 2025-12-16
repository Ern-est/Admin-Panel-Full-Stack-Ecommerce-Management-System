import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  static late final SupabaseClient supabase;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env'); // relative path from project root

    supabase = SupabaseClient(
      dotenv.env['SUPABASE_URL']!,
      dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }
}
