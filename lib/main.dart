// // Copyright 2017 The Chromium Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.
//
// import 'dart:async';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:healthchain/notification/in_app_notification.dart';
// import 'package:healthchain/services/auth_service.dart';
// import 'routes.dart';
// import 'firebase_options.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   InAppNotification().initNotifications();
//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//   FirebaseMessaging.onMessage.listen(firebaseMessagingBackgroundHandler);
//   Get.putAsync(() => AuthService().init());
//   runApp(const MyApp());
// }
//
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel', // id
//       'High Importance Notifications', // title
//       description: 'This channel is used for important notifications.',
//       importance: Importance.max,
//       playSound: true);
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print("message: $message");
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//
//     // If `onMessage` is triggered with a notification, construct our own
//     // local notification to show to users using the created channel.
//     if (notification != null && android != null) {
//       flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               icon: "@mipmap/ic_launcher",
//               // other properties...
//             ),
//           ));
//     }
//   });
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     const String appTitle = "HealthChain App";
//     return GetMaterialApp(
//       theme: ThemeData(
//         // colorScheme: ColorScheme.fromSeed(
//         //         seedColor: const Color.fromRGBO(220, 242, 241, 1))
//         //     .copyWith(
//         //   primary: const Color.fromRGBO(220, 242, 241, 1),
//         // ),
//         appBarTheme: AppBarTheme(
//             elevation: 4.0,
//             backgroundColor: Colors.white,
//             shadowColor: Colors.transparent,
//             titleTextStyle: TextStyle(color: Colors.grey.shade800,
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold),
//             toolbarTextStyle: const TextStyle(
//                 color: Colors.black, fontSize: 15)),
//       ),
//       debugShowCheckedModeBanner: false,
//       title: appTitle,
//       initialRoute: Routes.home,
//       getPages: appPages,
//     );
//   }
// }

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthchain/providers/setting_provider.dart';
import 'package:healthchain/services/auth_service.dart';
import 'routes.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:healthchain/providers/providers.dart';
import 'package:healthchain/providers/auth_provider.dart' as AuthPro;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  await dotenv.load(fileName: "lib/.env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initNotifications();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(firebaseMessagingBackgroundHandler);
  Get.putAsync(() => AuthService().init());
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

Future<void> initNotifications() async {
  final _firebaseMessaging = FirebaseMessaging.instance;
  const storage = FlutterSecureStorage();
  await _firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  final fcmToken = await _firebaseMessaging.getToken();
  await storage.write(key: "fcmToken", value: fcmToken);
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("message: $message");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: "@mipmap/ic_launcher",
              // other properties...
            ),
          ));
    }
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    const String appTitle = "HealthChain App";
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthPro.AuthProvider>(
          create: (_) => AuthPro.AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        Provider<SettingProvider>(
          create: (_) => SettingProvider(
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
          ),
        ),
        Provider<ChatHomeProvider>(
          create: (_) => ChatHomeProvider(
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        Provider<ChatProvider>(
          create: (_) => ChatProvider(
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
          ),
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            surfaceTintColor: Colors.transparent,
              titleTextStyle: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
              toolbarTextStyle:
              const TextStyle(color: Colors.black, fontSize: 15)),
        ),
        title: appTitle,
        initialRoute: Routes.home,
        getPages: appPages,
      ),
    );
  }
}
