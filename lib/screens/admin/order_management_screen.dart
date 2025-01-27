import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_order_card.dart';

class OrderManagementScreen extends StatefulWidget {
  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getOrders(String? statusFilter) {
    if (statusFilter == null) {
      return _firestore
          .collection('orders')
          .orderBy('order_date', descending: true)
          .snapshots();
    }
    if (statusFilter == 'Approved') {
      return _firestore
          .collection('orders')
          .where('status', whereIn: ['Shipped', 'Delivered'])
          .orderBy('order_date', descending: true)
          .snapshots();
    }
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: statusFilter)
        .orderBy('order_date', descending: true)
        .snapshots();
  }

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
              'Order Management',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Orders'),
            Tab(text: 'Approved'),
            Tab(text: 'Need Approval'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Orders Tab
          OrderList(
            stream: _getOrders(null),
            showStatusUpdate: false,
          ),
          // Approved Orders Tab
          OrderList(
            stream: _getOrders('Approved'),
            showStatusUpdate: true,
          ),
          // Need Approval Tab
          OrderList(
            stream: _getOrders('Processing'),
            showStatusUpdate: true,
          ),
        ],
      ),
    );
  }
}

class OrderList extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final bool showStatusUpdate;

  const OrderList({
    required this.stream,
    required this.showStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data?.docs ?? [];

        if (orders.isEmpty) {
          return Center(child: Text('No orders found'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderData = orders[index].data() as Map<String, dynamic>;
            return AdminOrderCard(
              order: orderData,
              orderId: orders[index].id,
              showStatusUpdate: showStatusUpdate,
            );
          },
        );
      },
    );
  }
}
