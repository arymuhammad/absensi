import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'navigator_helper.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null) return;

        final data = jsonDecode(response.payload!);

        // debugPrint('LOCAL NOTIFICATION CLICKED: $data');

        NotificationNavigation.handleNotificationMap(data);
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'approval_channel',
      'Approval Notification',
      description: 'Notifikasi Approval',
      importance: Importance.max,
      playSound: true,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> show({
    required String title,
    // required String body,
    required String name,
    required String msg,
    required Map<String, dynamic> data,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'approval_channel',
        'Approval Notification',
        channelDescription: 'Notifikasi Approval',
        importance: Importance.max,
        priority: Priority.high,
        setAsGroupSummary: false,
        styleInformation: BigTextStyleInformation(
          // '$body\n$name\n$msg',
          '${name.capitalize}\n${msg.capitalizeFirst}',
          contentTitle: title,
          summaryText: name,
        ),
        playSound: true,
      ),
    );

    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      // '$body\n$name\n$msg',
      '${name.capitalize}\n${msg.capitalizeFirst}',
      details,
      payload: jsonEncode(data),
    );
  }

  static void showNotifOpenedApp(RemoteMessage message) {
    Get.snackbar(
      '',
      '',
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 16,
      backgroundColor: Colors.white,
      colorText: Colors.black,
      duration: const Duration(seconds: 5),
      padding: EdgeInsets.zero,
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          // Foto Profil
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: 12,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.green,
              child: Text(
                (message.data['nama'] ?? '')
                    .toString()
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          // Nama & Pesan
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, right: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text(
                  //   message.data['body'] ?? '',
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: const TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 15,
                  //   ),
                  // ),
                  Text(
                    (message.data['title'] ?? '').toString().capitalize ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (message.data['nama'] ?? '').toString().capitalize ?? '',
                    style: const TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (message.data['msg'] ?? '').toString().capitalizeFirst ??
                        '',
                    style: const TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      onTap: (_) {
        Get.closeCurrentSnackbar();
        NotificationNavigation.handleNotificationRm(message);
      },
    );
  }

  static Future<Map<String, dynamic>?> getLaunchPayload() async {
    final details = await plugin.getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp ?? false) {
      final payload = details!.notificationResponse?.payload;

      if (payload != null) {
        return Map<String, dynamic>.from(jsonDecode(payload));
      }
    }

    return null;
  }
}
