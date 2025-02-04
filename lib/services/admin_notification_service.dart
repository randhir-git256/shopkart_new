import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../firebase_config.dart';
import 'package:googleapis_auth/auth_io.dart';

class AdminNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String projectId = Config.projectId;
  late AccessToken _accessToken;

  Future<void> _getAccessToken() async {
    final credentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": Config.projectId,
      "private_key_id": Config.privateKeyId,
      "private_key": Config.privateKey,
      "client_email": Config.clientEmail,
      "client_id": Config.clientId,
    });

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(credentials, scopes);
    _accessToken = client.credentials.accessToken;
  }

  Future<void> sendNewProductNotification(String productName) async {
    final message = {
      'message': {
        'topic': 'new_products',
        'notification': {
          'title': 'New Product Available!',
          'body': 'Check out our new product: $productName'
        }
      }
    };

    await _sendFcmMessage(message);
  }

  Future<void> sendOrderStatusUpdate(
    String userId,
    String orderId,
    String newStatus,
  ) async {
    final message = {
      'message': {
        'topic': 'order_updates_$userId',
        'notification': {
          'title': 'Order Status Update',
          'body': 'Your order #$orderId has been $newStatus'
        }
      }
    };

    await _sendFcmMessage(message);
  }

  Future<void> _sendFcmMessage(Map<String, dynamic> message) async {
    await _getAccessToken();

    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_accessToken.data}',
        },
        body: json.encode(message),
      );

      if (response.statusCode != 200) {
        print('FCM Error Response: ${response.body}');
        throw Exception('Failed to send FCM message');
      }
    } catch (e) {
      print('Error sending FCM message: $e');
    }
  }
}
