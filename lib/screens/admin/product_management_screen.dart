import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product.dart';
import '../../utils/helpers.dart';
import '../../widgets/product_dialogs.dart';

class ProductManagementScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
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
              'Products Inventory',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: FilledButton.icon(
                onPressed: () => _handleAddProduct(context),
                icon: Icon(Icons.add),
                label: Text('Add New Product'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            // child: FilledButton.icon(
            //   onPressed: () => _handleAddProduct(context),
            //   icon: Icon(Icons.add),
            //   label: Text('Add New Product'),
            //   style: FilledButton.styleFrom(
            //     backgroundColor: Colors.blue,
            //     foregroundColor: Colors.white,
            //   ),
            // ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data?.docs ?? [];

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = Product.fromFirestore(
                        products[index].data() as Map<String, dynamic>,
                        products[index].id);
                    return _buildProductCard(context, product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(product.imageUrl, width: 50),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            CurrencyUtils.formatPrice(product.price),
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () => _updateQuantity(product, -1),
                      ),
                      Text(
                        '${product.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () => _updateQuantity(product, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _handleEditProduct(context, product),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteProduct(context, product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateQuantity(Product product, int change) async {
    final newQuantity = product.quantity + change;
    if (newQuantity >= 0) {
      await _firestore.collection('products').doc(product.id).update({
        'quantity': newQuantity,
      });
    }
  }

  Future<void> _handleAddProduct(BuildContext context) async {
    await ProductDialogs.showAddProductDialog(
      context,
      (name, price, description, imageUrl, quantity) async {
        try {
          await _firestore.collection('products').add({
            'name': name,
            'price': price,
            'description': description,
            'imageUrl': imageUrl,
            'quantity': quantity,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product added successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding product: $e')),
          );
        }
      },
    );
  }

  Future<void> _handleEditProduct(BuildContext context, Product product) async {
    await ProductDialogs.showEditProductDialog(
      context,
      product,
      (name, price, description, imageUrl, quantity) async {
        try {
          await _firestore.collection('products').doc(product.id).update({
            'name': name,
            'price': price,
            'description': description,
            'imageUrl': imageUrl,
            'quantity': quantity,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product updated successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating product: $e')),
          );
        }
      },
    );
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('products').doc(product.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    }
  }
}
