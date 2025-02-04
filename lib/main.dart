import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shopkart/screens/home/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/auth/login_screen.dart';
import 'firebase_config.dart'; // Import the config file
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'database/local_database.dart';
import 'services/sync_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Config.apiKey,
      appId: Config.appId,
      messagingSenderId: Config.messagingSenderId,
      projectId: Config.projectId,
    ),
  );

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize local database
  final database = await LocalDatabase.getInstance();

  // Initialize sync service
  final syncService = SyncService(database);

  // Start sync
  print('Starting database synchronization...');
  syncService.startSync();

  // Debug: Print database contents after 5 seconds
  Future.delayed(Duration(seconds: 5), () {
    database.printDatabaseContents();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shopping App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isInitialized) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return authProvider.isAuthenticated() ? HomeScreen() : LoginScreen();
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Demo'),
      ),
      body: const Center(
        child: Text(
          'Hello Firebase',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
