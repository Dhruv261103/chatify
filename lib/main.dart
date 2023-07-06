import 'package:chatify/screens/auth/Login_Screen.dart';
import 'package:chatify/screens/flash_screen.dart';
import 'package:chatify/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatify/firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value) {
    initializefirebase();
    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatify',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          titleTextStyle:  TextStyle(fontSize: 20,fontWeight: FontWeight.normal,color: Colors.black),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),

      ),
      home: const flashscreen(),
    );
  }
}

initializefirebase() async
{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    allowBubbles: true,
    enableVibration: true,
    enableSound: true,
    showBadge: true,
  );
  // print(result);


}