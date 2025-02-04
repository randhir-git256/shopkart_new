import 'package:flutter/material.dart';
import '../database/local_database.dart';
import 'package:drift/drift.dart' as drift;

class LocalDatabaseViewScreen extends StatelessWidget {
  final LocalDatabase localDatabase;

  LocalDatabaseViewScreen({required this.localDatabase});

  Future<List<LocalUser>> _getUsers() async {
    return await localDatabase.getAllUsers();
  }

  Future<List<LocalProduct>> _getProducts() async {
    return await localDatabase.getAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Database Contents'),
      ),
      body: FutureBuilder(
        future: Future.wait([_getUsers(), _getProducts()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data![0] as List<LocalUser>;
          final products = snapshot.data![1] as List<LocalProduct>;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Users:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user.name),
                      subtitle: Text('${user.email} - ${user.role}'),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Products:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                          'Price: \$${product.price} (Qty: ${product.quantity})'),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
