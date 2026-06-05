import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'package:pesaplan_new/screens/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 ALWAYS initialize dotenv (flutter_dotenv v5 compatible)
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Initialize with empty content so dotenv.env is safe
    dotenv.testLoad(fileInput: '');
  }

  // 🔥 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ⏰ Timezone
  tz.initializeTimeZones();

  // 🔔 Notifications
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidInitSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
  InitializationSettings(android: androidInitSettings);

  await notificationsPlugin.initialize(initSettings);

  runApp(
    PesaPlanApp(
      notificationsPlugin: notificationsPlugin,
    ),
  );
}

class PesaPlanApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const PesaPlanApp({
    super.key,
    required this.notificationsPlugin,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PesaPlan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: AppShell(
        notificationsPlugin: notificationsPlugin,
      ),
    );
  }
}
