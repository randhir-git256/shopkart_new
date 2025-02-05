import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/local_database.dart';
import 'package:drift/drift.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  final LocalDatabase _localDb;
  final FirebaseFirestore _firestore;
  List<StreamSubscription> _subscriptions = [];
  DateTime? _lastSyncTimestamp;
  static const Duration SYNC_INTERVAL = Duration(minutes: 15);

  SyncService(this._localDb) : _firestore = FirebaseFirestore.instance {
    // Load last sync timestamp from SharedPreferences
    _loadLastSyncTimestamp();
  }

  Future<void> _loadLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_sync_timestamp');
    if (timestamp != null) {
      _lastSyncTimestamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
  }

  Future<void> _updateLastSyncTimestamp() async {
    _lastSyncTimestamp = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'last_sync_timestamp', _lastSyncTimestamp!.millisecondsSinceEpoch);
  }

  Stream<void> syncUsers() {
    print('Starting user sync service...');
    return _firestore
        .collection('users')
        .where('lastUpdated', isGreaterThan: _lastSyncTimestamp)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        print('No user updates found');
        return;
      }

      print('Received ${snapshot.docs.length} updated users from Firestore');

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
        } catch (e) {
          print('Error syncing user ${userData['email']}: $e');
        }
      }

      await _updateLastSyncTimestamp();
    });
  }

  Stream<void> syncProducts() {
    print('Starting product sync service...');
    return _firestore
        .collection('products')
        .where('lastUpdated', isGreaterThan: _lastSyncTimestamp)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        print('No product updates found');
        return;
      }

      print('Received ${snapshot.docs.length} updated products from Firestore');

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

  void startSync() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      print('Skipping sync - no network connection');
      return;
    }

    if (_lastSyncTimestamp == null ||
        DateTime.now().difference(_lastSyncTimestamp!) > SYNC_INTERVAL) {
      print('Initializing database sync...');
      _subscriptions.add(syncUsers().listen((event) {}));
      _subscriptions.add(syncProducts().listen((event) {}));
    }
  }

  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
