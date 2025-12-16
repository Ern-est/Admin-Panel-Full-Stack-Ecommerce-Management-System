class Order {
  final String id;
  final String clientName;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String? assignedToId; // Staff ID
  final String? assignedToName; // Staff name/email

  Order({
    required this.id,
    required this.clientName,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.assignedToId,
    this.assignedToName,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    final client = map['clients'];
    final staff = map['staff']; // join from Supabase

    return Order(
      id: map['id'],
      clientName:
          client != null
              ? client['name'] ?? 'Unnamed Client'
              : 'Unknown Client',
      status: map['order_status'] ?? 'pending',
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      assignedToId: map['assigned_to'],
      assignedToName:
          staff != null ? staff['full_name'] ?? staff['email'] : null,
    );
  }
}
