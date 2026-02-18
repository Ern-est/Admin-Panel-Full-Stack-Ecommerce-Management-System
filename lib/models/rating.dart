class Rating {
  final String id;
  final String productId;
  final String clientId;
  final String? orderId;
  final int rating;
  final String? comment;
  final bool verified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? clientName;
  final String? productName;

  Rating({
    required this.id,
    required this.productId,
    required this.clientId,
    this.orderId,
    required this.rating,
    this.comment,
    required this.verified,
    required this.createdAt,
    this.updatedAt,
    this.clientName,
    this.productName,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now(); // fallback if null
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Rating(
      id: map['id'] ?? '',
      productId: map['product_id'] ?? '',
      clientId: map['client_id'] ?? '',
      orderId: map['order_id'],
      rating: map['rating'] ?? 1,
      comment: map['comment'],
      verified: map['verified'] ?? false,
      createdAt: parseDate(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? parseDate(map['updated_at']) : null,
      clientName: map['clients']?['name'],
      productName: map['products']?['name'],
    );
  }
}
