import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/helpers.dart';

class AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String orderId;
  final bool showStatusUpdate;

  const AdminOrderCard({
    required this.order,
    required this.orderId,
    required this.showStatusUpdate,
  });

  Future<void> _updateOrderStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
      });

      // Update status in user's order history as well
      await FirebaseFirestore.instance
          .collection('users')
          .doc(order['user_id'])
          .collection('order_history')
          .doc(orderId)
          .update({
        'status': newStatus,
      });
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text('Order #${orderId.substring(0, 8)}'),
        subtitle: Text('Status: ${order['status']}'),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Details:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                ...(order['products'] as List).map((product) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(product['name']),
                        ),
                        Text('${product['quantity']}x'),
                        SizedBox(width: 16),
                        Text(CurrencyUtils.formatPrice(product['price'])),
                      ],
                    ),
                  );
                }).toList(),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyUtils.formatPrice(order['total_price']),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (showStatusUpdate) ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: order['status'],
                          decoration: InputDecoration(
                            labelText: 'Update Status',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            'Processing',
                            'Shipped',
                            'Delivered',
                          ].map((String status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _updateOrderStatus(newValue);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
