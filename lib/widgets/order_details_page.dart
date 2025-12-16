import 'package:flutter/material.dart';
import 'package:admin_panel/models/order.dart';
import 'package:admin_panel/models/order_item.dart';
import 'package:admin_panel/models/app_user.dart';
import 'package:admin_panel/services/order_service.dart';
import 'package:admin_panel/services/staff_service.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;
  final String role; // "admin" or "staff"

  const OrderDetailsPage({super.key, required this.order, required this.role});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  List<OrderItem> items = [];
  AppUser? assignedStaff;
  bool loading = true;
  bool assigning = false;
  bool updatingStatus = false;

  final List<String> statuses = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    loadOrderDetails();
  }

  Future<void> loadOrderDetails() async {
    setState(() => loading = true);
    items = await OrdersService.fetchOrderItems(widget.order.id);

    if (widget.order.assignedToId != null) {
      assignedStaff = await StaffService.getStaffById(
        widget.order.assignedToId!,
      );
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => updatingStatus = true);

    try {
      await OrdersService.updateOrderStatus(
        orderId: widget.order.id,
        status: newStatus,
      );

      if (!mounted) return;
      Navigator.pop(context, true); // refresh only after backend success
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status')),
      );
    } finally {
      if (mounted) {
        setState(() => updatingStatus = false);
      }
    }
  }

  Future<void> _showAssignStaffSheet() async {
    if (widget.role != 'admin') return;

    setState(() => assigning = true);
    final staffList = await StaffService.fetchStaff();
    setState(() => assigning = false);

    if (staffList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No staff available')));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Unassign Staff',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.pop(context);
                await OrdersService.updateOrderAssignment(
                  orderId: widget.order.id,
                  staffId: null,
                );
                assignedStaff = null;
                loadOrderDetails();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order unassigned')),
                );
                Navigator.pop(context, true);
              },
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: staffList.length,
                itemBuilder: (_, i) {
                  final staff = staffList[i];
                  return ListTile(
                    title: Text(
                      staff.fullName ?? staff.email,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      staff.email,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await OrdersService.updateOrderAssignment(
                        orderId: widget.order.id,
                        staffId: staff.id,
                      );
                      assignedStaff = staff;
                      loadOrderDetails();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Assigned to ${staff.fullName ?? staff.email}',
                          ),
                        ),
                      );
                      Navigator.pop(context, true);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client: ${widget.order.clientName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('Status: ', style: TextStyle(color: Colors.white70)),
                if (widget.role == 'staff' &&
                    widget.order.assignedToId ==
                        StaffService.currentUserId) ...[
                  DropdownButton<String>(
                    value: widget.order.status,
                    dropdownColor: Colors.grey[900],
                    items:
                        statuses
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateStatus(value);
                      }
                    },
                  ),

                  if (updatingStatus) const CircularProgressIndicator(),
                ] else
                  Text(
                    widget.order.status,
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Assigned to: ${assignedStaff != null ? assignedStaff!.fullName ?? assignedStaff!.email : "Not yet assigned!"}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),

            // Admin assign button
            if (widget.role == 'admin')
              ElevatedButton(
                onPressed: assigning ? null : _showAssignStaffSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text(
                  assigning ? 'Loading...' : 'Assign Staff',
                  style: const TextStyle(color: Colors.white),
                ),
              ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const Text(
              'Order Items',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? const Text(
                  'No items found',
                  style: TextStyle(color: Colors.white70),
                )
                : Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return Card(
                        color: Colors.grey.shade900,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            item.productName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Qty: ${item.quantity}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
