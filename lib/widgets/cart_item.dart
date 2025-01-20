import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/helpers.dart';

class CartItem extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;
  final int quantity;
  final Function(int) onUpdateQuantity;

  const CartItem({
    required this.product,
    required this.onRemove,
    required this.quantity,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4), // Add spacing between items
      padding: const EdgeInsets.all(8), // Add padding for better UI
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyUtils.formatPrice(product.price),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (quantity > 1) {
                          onUpdateQuantity(quantity - 1);
                        } else {
                          onRemove();
                        }
                      },
                      padding: EdgeInsets.zero, // Remove extra padding
                    ),
                    Text('$quantity'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (quantity < product.quantity) {
                          onUpdateQuantity(quantity + 1);
                        }
                      },
                      padding: EdgeInsets.zero, // Remove extra padding
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Trailing Section
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyUtils.formatPrice(product.price * quantity),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
