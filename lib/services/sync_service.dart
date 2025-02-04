import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/local_database.dart';
import 'package:drift/drift.dart';
import 'dart:async';

class SyncService {
  final LocalDatabase _localDb;
  final FirebaseFirestore _firestore;
  List<StreamSubscription> _subscriptions = [];

  SyncService(this._localDb) : _firestore = FirebaseFirestore.instance;

  // Listen to user changes
  Stream<void> syncUsers() {
    print('Starting user sync service...');
    return _firestore
        .collection('users')
        .snapshots()
        .asyncMap((snapshot) async {
      print('Received ${snapshot.docs.length} users from Firestore');

      for (var doc in snapshot.docs) {
        final userData = doc.data();
        try {
          await _localDb.into(_localDb.localUsers).insertOnConflictUpdate(
                LocalUsersCompanion.insert(
                  userId: doc.id,
                  name: userData['name'] as String,
                  email: userData['email'] as String,
                  role: userData['role'] as String,
                ),
              );
          print('Successfully synced user: ${userData['email']}');
        } catch (e) {
          print('Error syncing user ${userData['email']}: $e');
        }
      }

      // Debug: Print all users from local database
      final localUsers = await _localDb.select(_localDb.localUsers).get();
      print('Current users in local database:');
      for (var user in localUsers) {
        print('- ${user.email} (${user.role})');
      }
    });
  }

  // Listen to product changes
  Stream<void> syncProducts() {
    print('Starting product sync service...');
    return _firestore
        .collection('products')
        .snapshots()
        .asyncMap((snapshot) async {
      print('Received ${snapshot.docs.length} products from Firestore');

      for (var doc in snapshot.docs) {
        final productData = doc.data();
        try {
          await _localDb.into(_localDb.localProducts).insertOnConflictUpdate(
                LocalProductsCompanion.insert(
                  productId: doc.id,
                  name: productData['name'] as String,
                  price: (productData['price'] as num).toDouble(),
                  description: productData['description'] as String,
                  imageUrl: productData['imageUrl'] as String,
                  quantity: productData['quantity'] as int,
                ),
              );
          print('Successfully synced product: ${productData['name']}');
        } catch (e) {
          print('Error syncing product ${productData['name']}: $e');
        }
      }

      // Debug: Print all products from local database
      final localProducts = await _localDb.select(_localDb.localProducts).get();
      print('Current products in local database:');
      for (var product in localProducts) {
        print('- ${product.name} (Qty: ${product.quantity})');
      }
    });
  }

  // Initialize sync
  void startSync() {
    print('Initializing database sync...');
    _subscriptions.add(syncUsers().listen((event) {}));
    _subscriptions.add(syncProducts().listen((event) {}));
    print('Sync streams started and subscribed');
  }

  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
