import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> saveOrder(Map<String, dynamic> order, String userId) async {
    final batch = _firestore.batch();

    // Create the order document
    final orderRef = _firestore.collection('orders').doc();
    final orderData = {
      ...order,
      'user_id': userId,
      'status': 'Processing',
      'order_id': orderRef.id,
    };

    batch.set(orderRef, orderData);

    // Add to user's order history
    final userOrderRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('order_history')
        .doc(orderRef.id);
    batch.set(userOrderRef, orderData);

    // Update product quantities
    for (var product in order['products']) {
      final productRef = _firestore.collection('products').doc(product['id']);
      final productDoc = await productRef.get();
      final currentQuantity = productDoc.data()?['quantity'] ?? 0;
      final orderQuantity = product['quantity'] as int;

      if (currentQuantity >= orderQuantity) {
        batch.update(productRef, {
          'quantity': currentQuantity - orderQuantity,
        });
      }
    }

    await batch.commit();
  }

  Future<void> updateOrderStatus(
      String orderId, String userId, String newStatus) async {
    final batch = _firestore.batch();

    // Update main orders collection
    final orderRef = _firestore.collection('orders').doc(orderId);
    batch.update(orderRef, {'status': newStatus});

    // Update user's order history
    final userOrderRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('order_history')
        .doc(orderId);
    batch.update(userOrderRef, {'status': newStatus});

    await batch.commit();
  }
}
