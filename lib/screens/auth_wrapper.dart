import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:pesaplan_new/screens/login_screen.dart';
import 'package:pesaplan_new/screens/budget_home_page.dart';

class AuthWrapper extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const AuthWrapper({
    super.key,
    required this.notificationsPlugin,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool showLogin = true;

  void toggleView() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user == null) {
      return LoginScreen(toggleView: toggleView);
    }

    return BudgetHomePage(
      notificationsPlugin: widget.notificationsPlugin,
    );
  }
}
