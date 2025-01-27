import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/order_item.dart'; // Import the OrderItem widget

class OrderHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context).user?.uid;

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
                'Your Orders',
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

      body: userId == null
          ? Center(child: Text('Please login to view orders'))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('order_history')
                  .orderBy('order_date', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final orders = snapshot.data?.docs ?? [];

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: orders.length,
                  padding: EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;
                    return OrderItem(order: order); // Use the OrderItem widget
                  },
                );
              },
            ),
    );
  }
}
