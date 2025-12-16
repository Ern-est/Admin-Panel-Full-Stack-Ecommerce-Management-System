class Rating {
  final String id;
  final String orderId;
  final String? clientName;
  final String? staffName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.orderId,
    this.clientName,
    this.staffName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      orderId: map['order_id'],
      clientName: map['clients']?['name'],
      staffName: map['staff']?['full_name'] ?? map['staff']?['email'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
