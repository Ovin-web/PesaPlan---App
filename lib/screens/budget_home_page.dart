import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:pesaplan_new/services/analytics_service.dart';
import 'package:pesaplan_new/services/income_service.dart';
import 'package:pesaplan_new/ai/spending_prediction_service.dart';
import 'package:pesaplan_new/screens/add_income_screen.dart';

class BudgetHomePage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const BudgetHomePage({
    super.key,
    required this.notificationsPlugin,
  });

  @override
  State<BudgetHomePage> createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  static bool _notificationScheduled = false;

  final String _uid = 'local_user';

  late final AnalyticsService _analyticsService;
  late final SpendingPredictionService _predictionService;
  late final IncomeService _incomeService;

  late Future<double> _incomeFuture;
  late Future<double> _expenseFuture;
  late Future<double> _predictionFuture;

  @override
  void initState() {
    super.initState();

    _analyticsService = AnalyticsService(uid: _uid);
    _predictionService = SpendingPredictionService(uid: _uid);
    _incomeService = IncomeService(uid: _uid);

    _loadDashboard();

    if (!_notificationScheduled) {
      _scheduleDailyReminder();
      _notificationScheduled = true;
    }
  }

  void _loadDashboard() {
    _incomeFuture = _incomeService.getCurrentMonthIncome();
    _expenseFuture = _analyticsService.getCurrentMonthSpending();
    _predictionFuture = _predictionService.predictNextMonthSpending();
  }

  // 🔔 Notifications safe
  Future<void> _scheduleDailyReminder() async {
    const android = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Expense reminder',
      importance: Importance.max,
      priority: Priority.high,
    );

    try {
      await widget.notificationsPlugin.zonedSchedule(
        0,
        'PesaPlan Reminder',
        "Don't forget to log expenses today!",
        _next8PM(),
        const NotificationDetails(android: android),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  tz.TZDateTime _next8PM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _goToAddIncome() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddIncomeScreen(incomeService: _incomeService),
      ),
    );

    if (result == true) {
      setState(() {
        _loadDashboard(); // 🔁 refresh after income added
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        _incomeFuture,
        _expenseFuture,
        _predictionFuture,
      ]),
      builder: (context, snapshot) {
        final income = snapshot.hasData ? snapshot.data![0] : 0.0;
        final expenses = snapshot.hasData ? snapshot.data![1] : 0.0;
        final prediction = snapshot.hasData ? snapshot.data![2] : 0.0;

        final balance = income - expenses;

        final savings = balance > 0 ? balance : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text("PesaPlan Dashboard"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.attach_money),
                onPressed: _goToAddIncome,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _loadDashboard(); // manual refresh
                  });
                },
              ),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _StatCard(
                  title: "Total Income (This Month)",
                  value: income,
                  icon: Icons.account_balance_wallet,
                ),
                _StatCard(
                  title: "Total Expenses (This Month)",
                  value: expenses,
                  icon: Icons.trending_down,
                ),
                _StatCard(
                  title: "Remaining Balance",
                  value: balance,
                  icon: Icons.savings,
                ),
                _StatCard(
                  title: "Possible Savings Left",
                  value: savings,
                  icon: Icons.star,
                ),
                _StatCard(
                  title: "Next Month Expected Spend (Trend)",
                  value: prediction,
                  icon: Icons.psychology,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title),
        subtitle: Text(
          "TZS ${value.toStringAsFixed(0)}",
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
