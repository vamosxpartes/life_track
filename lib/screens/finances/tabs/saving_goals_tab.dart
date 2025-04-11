import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:life_track/providers/providers.dart';
import 'package:life_track/screens/finances/widgets/saving_goal_card.dart';
import 'package:life_track/screens/finances/dialogs/saving_goal_dialogs.dart';

class SavingGoalsTab extends StatelessWidget {
  const SavingGoalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    
    return Consumer<FinancesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              'Error: ${provider.errorMessage}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (provider.savingGoals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.savings, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No hay metas de ahorro registradas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: provider.savingGoals.length,
          itemBuilder: (context, index) {
            final goal = provider.savingGoals[index];
            return SavingGoalCard(
              goal: goal,
              currencyFormat: currencyFormat,
              onTap: () {
                SavingGoalDialogs.showSavingGoalDetailsDialog(context, goal);
              },
              onEdit: () {
                SavingGoalDialogs.showEditSavingGoalDialog(context, goal);
              },
              onDelete: () {
                SavingGoalDialogs.showDeleteSavingGoalConfirmDialog(context, goal);
              },
            );
          },
        );
      },
    );
  }
} 