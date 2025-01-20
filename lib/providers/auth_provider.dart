// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AuthProvider with ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   User? _user;
//   Map<String, dynamic>? _userData;
//   bool _isInitialized = false;
//
//   // Add SharedPreferences keys
//   static const String KEY_EMAIL = 'email';
//   static const String KEY_PASSWORD = 'password';
//   static const String KEY_IS_LOGGED_IN = 'isLoggedIn';
//
//   User? get user => _user;
//   Map<String, dynamic>? get userData => _userData;
//   bool get isInitialized => _isInitialized;
//
//   AuthProvider() {
//     _initializeAuth();
//   }
//
//   Future<void> _initializeAuth() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isLoggedIn = prefs.getBool(KEY_IS_LOGGED_IN) ?? false;
//
//     if (isLoggedIn) {
//       final email = prefs.getString(KEY_EMAIL);
//       final password = prefs.getString(KEY_PASSWORD);
//
//       if (email != null && password != null) {
//         try {
//           await login(email, password);
//         } catch (e) {
//           // If auto-login fails, clear stored credentials
//           print('Auto-login failed: $e');
//           await prefs.clear();
//         }
//       } else {
//         // If credentials are incomplete, clear stored data
//         await prefs.clear();
//       }
//     }
//
//     _auth.authStateChanges().listen((User? user) {
//       _user = user;
//       _isInitialized = true;
//       notifyListeners();
//     });
//   }
//
//   Future<void> _fetchUserData() async {
//     if (_user != null) {
//       final doc = await _firestore.collection('users').doc(_user!.uid).get();
//       if (doc.exists) {
//         _userData = doc.data();
//         notifyListeners();
//       }
//     }
//   }
//
//   Future<bool> login(String email, String password) async {
//     try {
//       final UserCredential result = await _auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//       _user = result.user;
//       await _fetchUserData();
//
//       // Save credentials to SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(KEY_EMAIL, email);
//       await prefs.setString(KEY_PASSWORD, password);
//       await prefs.setBool(KEY_IS_LOGGED_IN, true);
//
//       notifyListeners();
//       return true;
//     } catch (e) {
//       print('Login error: $e');
//       rethrow;
//     }
//   }
//
//   Future<bool> signUp(String name, String email, String password) async {
//     try {
//       final UserCredential result = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       _user = result.user;
//
//       // Create user document in Firestore
//       await _firestore.collection('users').doc(_user!.uid).set({
//         'name': name,
//         'email': email,
//         'role': 'user',
//         'createdAt': DateTime.now().toIso8601String(),
//       });
//
//       _user = null; // Reset user so they have to login
//       notifyListeners();
//       return true;
//     } catch (e) {
//       print('Signup error: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> logout() async {
//     // Clear SharedPreferences first
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//
//     // Then sign out from Firebase
//     await _auth.signOut();
//     _user = null;
//     _userData = null;
//     notifyListeners();
//   }
//
//   bool isAuthenticated() {
//     return _user != null;
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isInitialized = false;

  // SharedPreferences keys
  static const String KEY_EMAIL = 'email';
  static const String KEY_PASSWORD = 'password';
  static const String KEY_IS_LOGGED_IN = 'isLoggedIn';

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(KEY_IS_LOGGED_IN) ?? false;

    if (isLoggedIn) {
      final email = prefs.getString(KEY_EMAIL);
      final password = prefs.getString(KEY_PASSWORD);

      if (email != null && password != null) {
        try {
          await login(email, password);
        } catch (e) {
          // If auto-login fails, clear stored credentials
          print('Auto-login failed: $e');
          await prefs.clear();
        }
      } else {
        // If credentials are incomplete, clear stored data
        await prefs.clear();
      }
    }

    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userData = doc.data();
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = result.user;
      await _fetchUserData();

      // Save credentials to SharedPreferences only during explicit login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(KEY_EMAIL, email);
      await prefs.setString(KEY_PASSWORD, password);
      await prefs.setBool(KEY_IS_LOGGED_IN, true);

      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store the temporary user reference
      final User? tempUser = result.user;

      if (tempUser != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(tempUser.uid).set({
          'name': name,
          'email': email,
          'role': 'user',
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Important: Sign out immediately after creating account
        await _auth.signOut();

        // Clear any existing stored credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        _user = null;
        _userData = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    // Clear SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Then sign out from Firebase
    await _auth.signOut();
    _user = null;
    _userData = null;
    notifyListeners();
  }

  bool isAuthenticated() {
    return _user != null;
  }
}