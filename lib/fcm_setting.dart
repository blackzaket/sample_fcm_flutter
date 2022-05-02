// import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void fcmSetting() async {
  // firebase core 기능 사용을 위한 필수 initializing
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true);

  // foreground에서의 푸시 알림 표시를 위한 알림 중요도 설정
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  // foreground에서의 푸시 알림 표시를 위한 local notifications 설정
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: IOSInitializationSettings()),
      onSelectNotification: (String? payload) async {});

  // foreground 푸시 알림 핸들링
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ));
    }
  });

  // 사용자가 푸시 알림을 허용했는지 확인 (optional)
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final isFCMEnabled = await prefs.getBool('FCM_ENABLED');
  if (isFCMEnabled == null || isFCMEnabled) {
    // firebase token 발급
    String? firebaseToken = await FirebaseMessaging.instance.getToken();

    // 서버로 firebase token 갱신
    if (firebaseToken != null) {
      // var dio = Dio();
      // final firebaseTokenUpdateResponse = await dio.put(
      //     '/token',
      //     data: {'token': firebaseToken});
      print(firebaseToken);
    }
  }
}