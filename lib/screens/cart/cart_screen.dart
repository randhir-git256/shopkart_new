import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';

import '../../services/database_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/cart_item.dart' as widget;
import '../../providers/auth_provider.dart';
import '../../widgets/dialogs.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.cart;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png', // Path to your image asset
              height: 30, // Adjust the height as needed
            ),
            SizedBox(width: 10), // Adds spacing between the image and text
            Text(
              'My Cart',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          // Cart Items List
          Expanded(
            child: cart.isNotEmpty
                ? ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items.values.toList()[index];
                      return widget.CartItem(
                        product: item.product,
                        quantity: item.quantity,
                        onRemove: () =>
                            cartProvider.removeFromCart(item.product),
                        onUpdateQuantity: (newQuantity) {
                          cartProvider.updateQuantity(
                              item.product, newQuantity);
                        },
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'Your cart is empty!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),

          // Checkout Section
          if (cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyUtils.formatPrice(cartProvider.totalPrice),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkout Button
                  ElevatedButton(
                    onPressed: () async {
                      if (cart.isNotEmpty) {
                        try {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          final userId = authProvider.user?.uid;

                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please login to place order')),
                            );
                            return;
                          }

                          await DatabaseService().saveOrder({
                            'products': cart
                                .map((p) => {
                                      'id': p.id,
                                      'name': p.name,
                                      'price': p.price,
                                      'quantity': cartProvider
                                              .items[p.id]?.quantity ??
                                          1, // Get actual quantity from cart
                                    })
                                .toList(),
                            'total_price': cartProvider.totalPrice,
                            'order_date': DateTime.now().toIso8601String(),
                          }, userId);

                          cartProvider.clearCart();

                          // Show success dialog
                          showSuccessDialog(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to place order: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Place Order',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
