class OrderItem {
  final String id;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    final product = map['products'];

    return OrderItem(
      id: map['id'],
      productName: product != null ? product['name'] : 'Unknown product',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}
