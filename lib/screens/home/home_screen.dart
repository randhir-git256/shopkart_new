import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/product_card.dart';
import '../../models/product.dart';
import '../cart/cart_screen.dart';
import '../orders/order_history_screen.dart';
import '../admin/product_management_screen.dart';
import '../../providers/cart_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../admin/order_management_screen.dart';
import '../local_database_view_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import '../../database/local_database.dart';
import 'dart:io';
import '../../services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  Offset _fabPosition = Offset(20, 580); // Initial position of the FAB
  String appVersion = "Loading...";
  String _searchQuery = '';
  late final LocalDatabase localDatabase;
  late final SyncService syncService;
  late Stream<ConnectivityResult> connectivityStream;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _initializeLocalDatabase();
    _initializeConnectivity();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "Version: ${packageInfo.version}";
    });
  }

  Future<void> _initializeLocalDatabase() async {
    localDatabase = await LocalDatabase.getInstance();
    syncService = SyncService(localDatabase);
  }

  void _initializeConnectivity() {
    connectivityStream =
        Connectivity().onConnectivityChanged.map((results) => results.first);
    connectivityStream.listen((ConnectivityResult result) {
      setState(() {
        isOffline = result == ConnectivityResult.none;
      });

      // Automatically fetch user data when network becomes available
      if (result != ConnectivityResult.none) {
        _retryFetchUserData();
      }
    });
  }

  Future<void> _retryFetchUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshUserData();
    setState(() {});
  }

  @override
  void dispose() {
    syncService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final isAdmin = userData?['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png', // Path to your image asset
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'ShopKart',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return cart.itemCount > 0
                      ? Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: userData == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isOffline
                          ? 'You are offline. Please check your connection.'
                          : 'Loading user data...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    if (isOffline) ...[
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _retryFetchUserData,
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            : Column(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(userData['name']),
                    accountEmail: Text(userData['email']),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        userData['name'][0].toUpperCase(),
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // ListTile(
                        //   leading: Icon(Icons.person_outline),
                        //   title: Text('Profile'),
                        // ),
                        ListTile(
                          leading: Icon(Icons.shopping_bag_outlined),
                          title: Text('Your Orders'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        if (isAdmin) ...[
                          ListTile(
                            leading: Icon(Icons.admin_panel_settings),
                            title: Text('Order Management'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderManagementScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text(appVersion),
                        ),
                        // ListTile(
                        //   leading: Icon(Icons.storage),
                        //   title: Text('View Local Database'),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => LocalDatabaseViewScreen(
                        //             localDatabase: localDatabase),
                        //       ),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await authProvider.logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 8.0),
                          Text('Logout', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Product>>(
                  stream: _databaseService.getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error loading products'),
                            if (isOffline)
                              Text(
                                  'You are offline. Products will sync when online.'),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final products = snapshot.data ?? [];
                    final filteredProducts = products.where((product) {
                      return product.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return Center(child: Text('No products available'));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: filteredProducts[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (isAdmin)
            Positioned(
              left: _fabPosition.dx,
              top: _fabPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _fabPosition += details.delta;
                  });
                },
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductManagementScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Products'),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
