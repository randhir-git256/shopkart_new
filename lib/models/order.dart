class Order {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> products;
  final double totalPrice;
  final DateTime orderDate;

  Order({
    required this.id,
    required this.userId,
    required this.products,
    required this.totalPrice,
    required this.orderDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'products': products,
      'total_price': totalPrice,
      'order_date': orderDate.toIso8601String(),
    };
  }
}
