import 'package:flutter/material.dart';
import 'package:pesaplan_new/models/savings_goal.dart';
import 'package:pesaplan_new/services/savings_goal_service.dart';

class SavingsGoalsScreen extends StatelessWidget {
  final SavingsGoalService goalService;

  const SavingsGoalsScreen({
    super.key,
    required this.goalService,
  });

  // --------------------------------------------------
  // Simple AI coaching logic
  // --------------------------------------------------
  String _aiAdvice(SavingsGoal goal) {
    final remaining =
        goal.targetAmount - goal.savedAmount;

    if (remaining <= 0) {
      return '🎉 Goal achieved! Great job.';
    }

    final days = goal.daysRemaining;

    if (days <= 0) {
      return '⚠️ Deadline passed. Consider extending the goal.';
    }

    final perDay = remaining / days;

    return '💡 Save ${perDay.toStringAsFixed(0)} per day to reach this goal on time.';
  }

  void _addMoneyDialog(
    BuildContext context,
    SavingsGoal goal,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to ${goal.title}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount =
                  double.tryParse(controller.text.trim()) ?? 0;

              if (amount > 0) {
                await goalService.addToGoal(
                  goalId: goal.id,
                  amount: amount,
                );
              }

              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<SavingsGoal>>(
        stream: goalService.streamGoals(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final goals = snapshot.data!;

          if (goals.isEmpty) {
            return const Center(
              child: Text('No savings goals yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 8,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Saved: ${goal.savedAmount.toStringAsFixed(0)} / '
                        '${goal.targetAmount.toStringAsFixed(0)}',
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _aiAdvice(goal),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () =>
                              _addMoneyDialog(context, goal),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Money'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
