import 'package:pesaplan_new/services/analytics_service.dart';
import 'package:pesaplan_new/ai/spending_prediction_service.dart';
import 'package:pesaplan_new/ai/external_ai_service.dart';

/// Conversation states
enum AiState {
  idle,
  savingOptions,
  budgetOptions,
}

class AiAssistantService {
  final AnalyticsService analyticsService;
  final SpendingPredictionService predictionService;
  final ExternalAiService? externalAiService;

  final List<String> _conversationMemory = [];
  AiState _state = AiState.idle;

  AiAssistantService({
    required this.analyticsService,
    required this.predictionService,
    this.externalAiService,
  });

  // ==================================================
  // MAIN ENTRY — ALWAYS RESPONDS
  // ==================================================
  Future<String> respond(String userMessage) async {
    final message = userMessage.trim().toLowerCase();

    if (message.isEmpty) {
      return _genericIntro();
    }

    _remember("User: $message");

    // 1️⃣ Handle numeric replies FIRST
    if (_isNumber(message)) {
      final reply = _handleNumber(int.parse(message));
      _remember("AI: $reply");
      return reply;
    }

    // 2️⃣ Greetings
    if (_isGreeting(message)) {
      _state = AiState.idle;
      return _greetingResponse();
    }

    // 3️⃣ Try external AI (optional)
    if (externalAiService != null) {
      try {
        final context = await _buildEliteContextSafe();
        final reply = await externalAiService!.getAiResponse(
          userMessage: message,
          context: context,
        );

        if (reply != null && reply.trim().isNotEmpty) {
          _remember("AI: $reply");
          return reply;
        }
      } catch (_) {
        // silently fall back
      }
    }

    // 4️⃣ Offline intelligent coach
    final fallback = await _offlineCoach(message);
    _remember("AI: $fallback");
    return fallback;
  }

  // ==================================================
  // CONTEXT (SAFE — NO CRASHES)
  // ==================================================
  Future<String> _buildEliteContextSafe() async {
    double spent = 0;
    double avg = 0;
    double predicted = 0;

    try {
      spent = await analyticsService.getCurrentMonthSpending();
      avg = await analyticsService.getAverageMonthlySpending();
      predicted = await predictionService.predictNextMonthSpending();
    } catch (_) {}

    final spendingPressure =
    avg == 0 ? "unknown" : (spent / avg > 1.1 ? "high" : "normal");

    return '''
SYSTEM ROLE:
World-class AI personal finance assistant.

USER SNAPSHOT:
• This month spending: TZS ${spent.toStringAsFixed(0)}
• Average spending: TZS ${avg.toStringAsFixed(0)}
• Predicted next month: TZS ${predicted.toStringAsFixed(0)}
• Spending pressure: $spendingPressure

Conversation:
${_conversationMemory.join('\n')}
''';
  }

  // ==================================================
  // OFFLINE AI COACH (STRUCTURED)
  // ==================================================
  Future<String> _offlineCoach(String message) async {
    // 💸 SAVING
    if (message.contains('save')) {
      _state = AiState.savingOptions;
      return await _savingOptions();
    }

    // 📊 BUDGET
    if (message.contains('budget')) {
      _state = AiState.budgetOptions;
      return _budgetOptions();
    }

    // 💰 SPENDING
    if (message.contains('spend') || message.contains('expense')) {
      double spent = 0;
      try {
        spent = await analyticsService.getCurrentMonthSpending();
      } catch (_) {}

      return '''
So far this month, you’ve spent **TZS ${spent.toStringAsFixed(0)}**.

Spending is not bad — *unplanned spending* is.

Would you like me to:
1️⃣ Analyze categories
2️⃣ Compare with last month
3️⃣ Suggest reductions

Reply with a number.
''';
    }

    // 🤔 HELP / CONFUSION
    if (message.contains('help') ||
        message.contains('confused') ||
        message.contains('dont know') ||
        message.contains('dont understand')) {
      return '''
That’s completely okay.

Money becomes easier when we:
• slow down
• clarify priorities
• improve one habit at a time

What feels hardest right now — saving, spending, or planning?
''';
    }

    // 🌱 DEFAULT
    return '''
That’s a good topic.

You can ask me things like:
• “How much should I save?”
• “Am I overspending?”
• “Help me plan my money”

What would you like to do?
''';
  }

  // ==================================================
  // OPTIONS
  // ==================================================
  Future<String> _savingOptions() async {
    double spent = 0;
    double avg = 0;

    try {
      spent = await analyticsService.getCurrentMonthSpending();
      avg = await analyticsService.getAverageMonthlySpending();
    } catch (_) {}

    return '''
Based on your data:

• This month spending: TZS ${spent.toStringAsFixed(0)}
• Average spending: TZS ${avg.toStringAsFixed(0)}

Choose an option:
1️⃣ Save safely (10%)
2️⃣ Save aggressively (20%)
3️⃣ Build emergency fund
4️⃣ Tell me your income first

Reply with a number (1–4)
''';
  }

  String _budgetOptions() {
    return '''
Budgeting works best when it’s simple.

Choose:
1️⃣ Tight budget
2️⃣ Balanced budget
3️⃣ Flexible budget

Reply with a number.
''';
  }

  // ==================================================
  // HANDLE NUMERIC REPLIES
  // ==================================================
  String _handleNumber(int choice) {
    switch (_state) {
      case AiState.savingOptions:
        _state = AiState.idle;
        if (choice == 1) {
          return 'Saving 10% is a safe and sustainable start 👍';
        }
        if (choice == 2) {
          return 'Saving 20% is powerful but needs discipline 🔥';
        }
        if (choice == 3) {
          return 'Emergency funds protect you from surprises 🛡';
        }
        if (choice == 4) {
          return 'Tell me your monthly income and I’ll calculate it.';
        }
        return 'Please choose between 1 and 4.';

      case AiState.budgetOptions:
        _state = AiState.idle;
        if (choice == 1) return 'Tight budgets work short-term.';
        if (choice == 2) return 'Balanced budgets are most sustainable.';
        if (choice == 3) return 'Flexibility helps consistency.';
        return 'Please choose 1–3.';

      default:
        return 'Please choose a valid option.';
    }
  }

  // ==================================================
  // GREETING (PRESERVED)
  // ==================================================
  String _greetingResponse() {
    return '''
Hi 👋 I’m your personal finance AI assistant.

I can help you with:
• saving money effectively
• budgeting without stress
• understanding expenses
• planning your future finances
• building better money habits
• acting as a basic calculator
• telling you where you exceeded your budget
• suggesting priorities aligned with saving
• reducing unnecessary costs

You can ask me anything.
What’s on your mind?
''';
  }

  // ==================================================
  // HELPERS
  // ==================================================
  bool _isGreeting(String text) {
    const greetings = [
      'hi',
      'hello',
      'hey',
      'good morning',
      'good afternoon',
      'good evening',
      'hii',
      'hey there',
      'yo',
      'howdy',
      'whats up',
      'how are you',
      'hows it going',
      'how are things',
      'oya',
      'vipi',
      'unaendeleaje',
      'kwema',
      'mzima',
      'tsup',
      'how is it',
      'are you okay',
      'how was your day',
      'how are you doing',
      'how are things going',
      'how is it going'
    ];
    return greetings.any(text.contains);
  }

  bool _isNumber(String text) {
    return int.tryParse(text) != null;
  }

  String _genericIntro() {
    return '''
I’m here and ready to help 😊

You can talk to me about:
• money
• budgeting
• saving
• expenses
• planning

What would you like to discuss?
''';
  }

  void _remember(String entry) {
    _conversationMemory.add(entry);
    if (_conversationMemory.length > 10) {
      _conversationMemory.removeAt(0);
    }
  }
}