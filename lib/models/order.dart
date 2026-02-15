class Order {
  final String id;
  final String clientName;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String? assignedToId; // Staff ID
  final String? assignedToName; // Staff name/email

  // Cancellation fields
  final String? cancelledBy; // 'admin' or 'client'
  final String? cancelReason;
  final DateTime? cancelledAt;

  Order({
    required this.id,
    required this.clientName,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.assignedToId,
    this.assignedToName,
    this.cancelledBy,
    this.cancelReason,
    this.cancelledAt,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    // Handle both nested clients object and flat client_name
    String clientName;
    if (map.containsKey('clients') && map['clients'] != null) {
      clientName = map['clients']['name'] ?? 'Unnamed Client';
    } else if (map.containsKey('client_name') && map['client_name'] != null) {
      clientName = map['client_name'];
    } else {
      clientName = 'Unknown Client';
    }

    final staff = map['staff'];

    return Order(
      id: map['id'],
      clientName: clientName,
      status: map['order_status'] ?? 'pending',
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      assignedToId: map['assigned_to'],
      assignedToName:
          staff != null ? staff['full_name'] ?? staff['email'] : null,
      cancelledBy: map['cancelled_by'],
      cancelReason: map['cancel_reason'],
      cancelledAt:
          map['cancelled_at'] != null
              ? DateTime.parse(map['cancelled_at'])
              : null,
    );
  }
}
