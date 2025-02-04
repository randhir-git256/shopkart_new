import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../database/local_database.dart';
import '../services/admin_notification_service.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final LocalDatabase _localDb;
  bool _isInitialized = false;

  DatabaseService() {
    _initializeLocalDb();
  }

  Future<void> _initializeLocalDb() async {
    if (!_isInitialized) {
      _localDb = await LocalDatabase.getInstance();
      _isInitialized = true;
    }
  }

  Stream<List<Product>> getProducts() async* {
    if (!_isInitialized) {
      await _initializeLocalDb();
    }

    yield* _localDb.select(_localDb.localProducts).watch().map((products) {
      return products.map((localProduct) {
        return Product(
          id: localProduct.productId,
          name: localProduct.name,
          price: localProduct.price,
          description: localProduct.description,
          imageUrl: localProduct.imageUrl,
          quantity: localProduct.quantity,
        );
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

    // Send notification
    final notificationService = AdminNotificationService();
    await notificationService.sendOrderStatusUpdate(userId, orderId, newStatus);
  }
}
