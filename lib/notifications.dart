import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await Firebase.initializeApp(); // 🔹 เรียกใช้งาน Firebase

    // 🔹 ขอสิทธิ์การแจ้งเตือนสำหรับ iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notifications are enabled");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("⚠️ Notifications are provisionally enabled");
    } else {
      print("❌ Notifications are not enabled");
      return; // ออกจากฟังก์ชันถ้าไม่ได้รับอนุญาต
    }

    // 🔹 ตั้งค่า Local Notification สำหรับ Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // ใช้ไอคอนแอป
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _localNotifications.initialize(initializationSettings);

    // 🔹 ดึง FCM Token
    await getToken();

    // 🔹 ตั้งค่า Listeners สำหรับการแจ้งเตือน
    setupForegroundListener();
    setupBackgroundHandler();
  }

  /// 🔹 ดึง FCM Token
  Future<void> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("🎯 FCM Token: $token");
  }

  /// 🔹 ตั้งค่า Listener สำหรับ Foreground Notification
  void setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground message received: ${message.notification?.title}");
      showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 User tapped the notification: ${message.notification?.title}");
    });
  }

  /// 🔹 ตั้งค่า Background Handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("⏳ Handling a background message: ${message.messageId}");
  }

  void setupBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// 🔹 แสดง Local Notification สำหรับ Android
  Future<void> showLocalNotification(RemoteMessage message) async {
    var bigPictureStyle = BigPictureStyleInformation(
      ByteArrayAndroidBitmap.fromBase64String(message.data['image'] ?? ''), // รองรับภาพ
      contentTitle: message.notification?.title,
      summaryText: message.notification?.body,
    );

    var androidDetails = AndroidNotificationDetails(
      'channel_id', 
      'channel_name',
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyle, 
      playSound: true,
      enableVibration: true,
    );
    
    var platformDetails = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
    );
  }
}
