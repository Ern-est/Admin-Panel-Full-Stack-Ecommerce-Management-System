import 'package:admin_panel/models/order.dart';
import 'package:admin_panel/services/order_service.dart';
import 'package:admin_panel/services/staff_service.dart';
import 'package:admin_panel/widgets/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  final String role; // "admin" or "staff"
  const OrdersPage({super.key, required this.role});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Order> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadOrders();

    // Subscribe to real-time updates
    OrdersService.subscribeOrders(
      onUpdate: (updatedOrder) {
        if (mounted) {
          setState(() {
            final index = orders.indexWhere((o) => o.id == updatedOrder.id);
            if (index != -1) {
              orders[index] = updatedOrder;
            } else if (widget.role == 'admin') {
              // Admin sees all orders
              orders.insert(0, updatedOrder);
            }
          });
        }
      },
    );
  }

  Future<void> loadOrders() async {
    setState(() => loading = true);

    List<Order> res = [];
    if (widget.role == 'admin') {
      res = await OrdersService.fetchAllOrders();
    } else {
      res = await StaffService.fetchAssignedOrders();
    }

    if (mounted) {
      setState(() {
        orders = res;
        loading = false;
      });
    }
  }

  String formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd – kk:mm').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.grey[900],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
              ? const Center(
                child: Text(
                  'No orders found',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : RefreshIndicator(
                onRefresh: loadOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (_, i) {
                    final order = orders[i];
                    return Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => OrderDetailsPage(
                                    order: order,
                                    role: widget.role,
                                  ),
                            ),
                          );
                          if (updated == true) loadOrders();
                        },
                        title: Text(
                          'Client: ${order.clientName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              'Status: ${order.status}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Assigned to: ${order.assignedToName ?? "Not yet assigned!"}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Created: ${formatDate(order.createdAt)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
