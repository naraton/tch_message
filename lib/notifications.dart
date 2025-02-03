import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  late FirebaseMessaging messaging;
  late FlutterLocalNotificationsPlugin localNotifications;

  FirebaseNotificationService() {
    messaging = FirebaseMessaging.instance;
    localNotifications = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // ตั้งค่า Notification Channel สำหรับ Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon'); // ใช้แอปไอคอนที่ต้องการ
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await localNotifications.initialize(initializationSettings);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await requestNotificationPermission();
    await getToken();
    setupForegroundListener();
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
  }

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Notification permission granted.");
    } else {
      print("Notification permission denied.");
    }
  }

  Future<void> getToken() async {
    String? token = await messaging.getToken();
    print("FCM Token: $token");
  }

  void setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received message: ${message.notification?.title}");
      showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Tapped notification: ${message.notification?.title}");
    });
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    /* var bigPictureStyle = BigPictureStyleInformation(
      ByteArrayAndroidBitmap.fromBase64String(message.data['image'] ?? ''),
      largeIcon: message.data['icon'] != null
          ? ByteArrayAndroidBitmap.fromBase64String(message.data['icon'])
          : null, // ตรวจสอบว่า icon ไม่เป็น null ก่อน
      contentTitle: message.notification?.title,
      summaryText: message.notification?.body,
    ); */

    var bigPictureStyle = BigPictureStyleInformation(
      ByteArrayAndroidBitmap.fromBase64String(message.data['image'] ?? ''),
      contentTitle: message.notification?.title,
      summaryText: message.notification?.body,
    );

    var android = AndroidNotificationDetails(
      'channel_id', 
      'channel_name',
      icon: 'app_icon',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyle, // เพิ่ม styleInformation
      playSound: true,  // ให้เล่นเสียง
      enableVibration: true, // ให้สั่น
    );
    var platform = NotificationDetails(android: android);
    await localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platform,
    );
  }
}
