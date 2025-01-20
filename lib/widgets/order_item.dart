import 'package:flutter/material.dart';
import '../../utils/helpers.dart';

class OrderItem extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderItem({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text(
          'Order #${order['order_id']} - Total: ${CurrencyUtils.formatPrice(order['total_price'])}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Date: ${order['order_date']}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...(order['products'] as List).map((product) {
                  return ListTile(
                    dense: true,
                    title: Text(product['name']),
                    subtitle: Text(
                      'Price: ${CurrencyUtils.formatPrice(product['price'])}, Quantity: ${product['quantity']}',
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
