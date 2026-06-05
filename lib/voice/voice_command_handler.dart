import 'package:pesaplan_new/services/analytics_service.dart';
import 'package:pesaplan_new/ai/spending_prediction_service.dart';
import 'package:pesaplan_new/services/voice_service.dart';

class VoiceCommandHandler {
  final VoiceService voiceService;
  final AnalyticsService analyticsService;
  final SpendingPredictionService predictionService;

  VoiceCommandHandler({
    required this.voiceService,
    required this.analyticsService,
    required this.predictionService,
  });

  // --------------------------------------------------
  // Process voice command
  // --------------------------------------------------
  Future<void> handleCommand() async {
    final command = await voiceService.listen();

    if (command.isEmpty) {
      await voiceService.speak("I didn't hear anything.");
      return;
    }

    if (command.contains('this month')) {
      final spent =
          await analyticsService.getCurrentMonthSpending();

      await voiceService.speak(
        "You have spent ${spent.toStringAsFixed(0)} shillings this month.",
      );
      return;
    }

    if (command.contains('average')) {
      final avg =
          await analyticsService.getAverageMonthlySpending();

      await voiceService.speak(
        "Your average monthly spending is ${avg.toStringAsFixed(0)} shillings.",
      );
      return;
    }

    if (command.contains('predict') ||
        command.contains('next month')) {
      final prediction =
          await predictionService.predictNextMonthSpending();

      await voiceService.speak(
        "I predict you will spend around ${prediction.toStringAsFixed(0)} shillings next month.",
      );
      return;
    }

    await voiceService.speak(
      "Sorry, I did not understand that command yet.",
    );
  }
}
