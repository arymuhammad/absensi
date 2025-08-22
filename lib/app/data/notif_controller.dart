// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class NotificationController extends GetxController {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   var fcmToken = ''.obs;
//   var serverUrl = dotenv.env['API_URL']; // Ganti sesuai backend Anda
//   final String userId; // User ID dari login Anda

//   NotificationController(this.userId);

//   @override
//   void onInit() {
//     super.onInit();
//     requestPermission();
//     getTokenAndSendToServer();
//     setupTokenRefreshListener();
//   }

//   void requestPermission() async {
//     await _messaging.requestPermission(alert: true, badge: true, sound: true);
//   }

//   void getTokenAndSendToServer() async {
//     String? token = await _messaging.getToken();
//     if (token != null) {
//       fcmToken.value = token;
//       print('FCM Token: $token');
//       await sendTokenToServer(token);
//     }
//   }

//   void setupTokenRefreshListener() {
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
//       fcmToken.value = newToken;
//       print('Refreshed FCM Token: $newToken');
//       await sendTokenToServer(newToken);
//     });
//   }

//   Future<void> sendTokenToServer(String token) async {
//     try {
//       var response = await http.post(
//         Uri.parse('$serverUrl/fcm_token/update'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'id_user': userId, 'fcm_token': token}),
//       );
//       if (response.statusCode == 200) {
//         print('Token updated on server');
//       } else {
//         print('Failed to update token on server');
//       }
//     } catch (e) {
//       print('Error sending token to server: $e');
//     }
//   }

//   Future<void> removeTokenFromServer() async {
//     try {
//       var response = await http.post(
//         Uri.parse('$serverUrl/fcm_token/remove'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'id_user': userId}),
//       );
//       if (response.statusCode == 200) {
//         print('Token removed on server');
//       } else {
//         print('Failed to remove token on server');
//       }
//     } catch (e) {
//       print('Error removing token from server: $e');
//     }
//   }

//   void setupMessageHandlers() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Foreground message received: ${message.notification?.title}');
//       // Tambahkan local notification jika perlu
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Notification clicked: ${message.notification?.title}');
//       // Handle klik notifikasi, misal navigasi ke halaman tertentu
//     });
//   }
// }
