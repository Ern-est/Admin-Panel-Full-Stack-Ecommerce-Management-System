import 'package:admin_panel/models/order.dart';
import 'package:admin_panel/models/order_item.dart';
import '../core/config.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersService {
  static Future<List<Order>> fetchAllOrders() async {
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
          .order('created_at', ascending: false);

      return res.map((e) => Order.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Fetch admin orders error: $e');
      return [];
    }
  }

  static Future<List<OrderItem>> fetchOrderItems(String orderId) async {
    try {
      final List<dynamic> res = await AppConfig.supabase
          .from('order_items')
          .select('''
            id,
            quantity,
            unit_price,
            total_price,
            products(name)
          ''')
          .eq('order_id', orderId);

      return res
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Fetch order items error: $e');
      return [];
    }
  }

  static Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await AppConfig.supabase
        .from('orders')
        .update({'order_status': status})
        .eq('id', orderId);
  }

  static Future<void> updateOrderAssignment({
    required String orderId,
    String? staffId, // null to unassign
  }) async {
    await AppConfig.supabase
        .from('orders')
        .update({
          'assigned_to': staffId,
          'order_status': staffId != null ? 'processing' : 'pending',
        })
        .eq('id', orderId);
  }

  /// Real-time subscription to order updates
  static void subscribeOrders({
    required Function(Order updatedOrder) onUpdate,
  }) {
    AppConfig.supabase.channel('orders_updates').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'UPDATE', schema: 'public', table: 'orders'),
      (payload, [ref]) {
        if (payload.newRecord != null) {
          final updatedOrder = Order.fromMap(
            payload.newRecord as Map<String, dynamic>,
          );
          onUpdate(updatedOrder);
        }
      },
    ).subscribe(); // No assignment needed
  }
}
