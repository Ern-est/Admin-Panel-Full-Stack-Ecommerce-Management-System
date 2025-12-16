import 'package:admin_panel/models/order.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config.dart';
import '../models/app_user.dart';
import 'package:flutter/foundation.dart';

class StaffService {
  /// Get the currently logged-in staff's ID
  static String? get currentUserId => AppConfig.supabase.auth.currentUser?.id;

  /// Count orders assigned to the current staff by status
  static Future<int> countOrdersByStatus(String status) async {
    final staffId = currentUserId;
    if (staffId == null) return 0;

    final res = await AppConfig.supabase
        .from('orders')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('assigned_to', staffId)
        .eq('order_status', status);

    return res.count ?? 0;
  }

  /// Fetch orders assigned to current staff
  static Future<List<Order>> fetchAssignedOrders() async {
    final staffId = currentUserId;
    if (staffId == null) return [];

    try {
      final List<dynamic> res = await AppConfig.supabase
          .from('orders')
          .select('''
          id,
          order_status,
          total_amount,
          created_at,
          assigned_to,
          clients(name),
          staff:users!assigned_to(full_name,email)
        ''')
          .eq('assigned_to', staffId)
          .order('created_at', ascending: false);

      return res.map((e) => Order.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Fetch assigned orders error: $e');
      return [];
    }
  }

  /// Count all products
  static Future<int> countProducts() async {
    final res = await AppConfig.supabase
        .from('products')
        .select('id', const FetchOptions(count: CountOption.exact));

    return res.count ?? 0;
  }

  /// Create staff via Supabase Edge Function
  static Future<void> createStaff({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await AppConfig.supabase.functions.invoke(
      'create-staff',
      body: {'email': email, 'password': password, 'full_name': fullName},
    );
  }

  static Future<AppUser?> getStaffById(String staffId) async {
    try {
      final res =
          await AppConfig.supabase
              .from('users')
              .select()
              .eq('id', staffId)
              .single();
      return AppUser.fromMap(res);
    } catch (e) {
      debugPrint('Get staff by ID error: $e');
      return null;
    }
  }

  /// Fetch all staff (excluding admins)
  static Future<List<AppUser>> fetchStaff() async {
    try {
      final res = await AppConfig.supabase
          .from('users')
          .select()
          .neq('role', 'admin')
          .order('created_at');

      return (res as List)
          .map((e) => AppUser.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Fetch staff error: $e');
      return [];
    }
  }

  /// Update staff status (active / disabled)
  static Future<void> updateStatus({
    required String userId,
    required String status,
  }) async {
    await AppConfig.supabase
        .from('users')
        .update({'status': status})
        .eq('id', userId);
  }

  /// Delete staff (admin action)
  static Future<void> deleteStaff(String userId) async {
    await AppConfig.supabase.from('users').delete().eq('id', userId);
  }
}
