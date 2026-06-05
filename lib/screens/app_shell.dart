import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:pesaplan_new/screens/budget_home_page.dart';
import 'package:pesaplan_new/screens/budget_screen.dart';
import 'package:pesaplan_new/screens/add_expense_screen.dart';
import 'package:pesaplan_new/screens/ai_assistant_screen.dart';

import 'package:pesaplan_new/services/expense_service.dart';
import 'package:pesaplan_new/services/voice_service.dart';
import 'package:pesaplan_new/services/analytics_service.dart';
import 'package:pesaplan_new/ai/spending_prediction_service.dart';
import 'package:pesaplan_new/voice/voice_command_handler.dart';
import 'package:pesaplan_new/ai/ai_assistant_service.dart';
import 'package:pesaplan_new/ai/external_ai_service.dart';

class AppShell extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const AppShell({
    super.key,
    required this.notificationsPlugin,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final String _uid = 'local_user';

  late final ExpenseService _expenseService;
  late final VoiceCommandHandler _voiceHandler;
  late final AiAssistantService _assistantService;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _expenseService = ExpenseService(uid: _uid);

    final analyticsService = AnalyticsService(uid: _uid);
    final predictionService =
    SpendingPredictionService(uid: _uid);

    // 🔐 SAFE dotenv access (never crashes)
    final apiKey = dotenv.maybeGet('OPENAI_API_KEY');

    final externalAiService =
    (apiKey != null && apiKey.isNotEmpty)
        ? ExternalAiService(apiKey: apiKey)
        : null;

    _assistantService = AiAssistantService(
      analyticsService: analyticsService,
      predictionService: predictionService,
      externalAiService: externalAiService,
    );

    _voiceHandler = VoiceCommandHandler(
      voiceService: VoiceService(),
      analyticsService: analyticsService,
      predictionService: predictionService,
    );

    _pages = [
      BudgetHomePage(
        notificationsPlugin: widget.notificationsPlugin,
      ),
      const BudgetScreen(),
      const _PlaceholderScreen(title: 'Profile'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'voice',
            onPressed: () async {
              await _voiceHandler.handleCommand();
            },
            child: const Icon(Icons.mic),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(
                    expenseService: _expenseService,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'ai',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiAssistantScreen(
                    assistantService: _assistantService,
                  ),
                ),
              );
            },
            child: const Icon(Icons.psychology),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title coming soon')),
    );
  }
}
