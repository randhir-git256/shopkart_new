

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
          'Order #${order['order_id']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Status: ',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: '${order['status'] ?? 'Pending'}',
                style: TextStyle(
                  color: order['status'] == 'Delivered' ? Colors.green : Colors.blue,
                  fontWeight: order['status'] == 'Delivered' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...(order['products'] as List).map((product) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product ID: ${product['id']}',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${product['name']}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Text(
                            '${CurrencyUtils.formatPrice(product['price'])}',
                            style: TextStyle(color: Colors.green),
                          ),
                          Text(
                            'x: ${product['quantity']}',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                }).toList(),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Cost:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyUtils.formatPrice(order['total_price']),
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateTime.parse(order['order_date'])
                          .toLocal()
                          .toString()
                          .split('.')[0],
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}