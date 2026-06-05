import 'package:flutter/material.dart';
import 'package:pesaplan_new/models/budget.dart';
import 'package:pesaplan_new/models/category.dart';
import 'package:pesaplan_new/services/budget_service.dart';
import 'package:pesaplan_new/services/category_service.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Nala-style: local / device-first user
    const String localUid = 'local_user';

    final budgetService = BudgetService(uid: localUid);
    final categoryService = CategoryService(uid: localUid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budgets"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context, categoryService),
        label: const Text("Add Category"),
        icon: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<Category>>(
        stream: categoryService.categories,
        builder: (context, categorySnap) {
          if (categorySnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!categorySnap.hasData || categorySnap.data!.isEmpty) {
            return const Center(
              child: Text("No categories yet. Add one to begin."),
            );
          }

          final categories = categorySnap.data!;

          return StreamBuilder<List<Budget>>(
            stream: budgetService.budgets,
            builder: (context, budgetSnap) {
              final budgets = budgetSnap.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  final existingBudget = budgets.firstWhere(
                        (b) => b.category == category.name,
                    orElse: () =>
                        Budget(id: '', category: category.name, amount: 0),
                  );

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Budget: TZS ${existingBudget.amount.toStringAsFixed(2)}",
                      ),
                      trailing:
                      const Icon(Icons.edit, color: Colors.blue),
                      onTap: () => _showEditBudgetDialog(
                        context,
                        category.name,
                        existingBudget.amount,
                        budgetService,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // -----------------------------------------------------------
  // ADD NEW CATEGORY
  // -----------------------------------------------------------
  void _showAddCategoryDialog(
      BuildContext context,
      CategoryService service,
      ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Category name",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await service.addCategory(controller.text.trim());
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // EDIT BUDGET DIALOG
  // -----------------------------------------------------------
  void _showEditBudgetDialog(
      BuildContext context,
      String categoryName,
      double currentAmount,
      BudgetService service,
      ) {
    final controller =
    TextEditingController(text: currentAmount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set Budget for $categoryName"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Budget Amount (TZS)",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              final amount =
                  double.tryParse(controller.text.trim()) ?? 0.0;

              await service.setBudget(categoryName, amount);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
