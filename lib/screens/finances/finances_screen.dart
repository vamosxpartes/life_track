import 'package:flutter/material.dart';
import 'package:life_track/main.dart'; // Importar colores
import 'package:life_track/screens/finances/tabs/accounts_tab.dart';
import 'package:life_track/screens/finances/tabs/transactions_tab.dart';
import 'package:life_track/screens/finances/tabs/saving_goals_tab.dart';
import 'package:life_track/screens/finances/tabs/recurring_expenses_tab.dart';
import 'package:life_track/screens/finances/dialogs/account_dialogs.dart';
import 'package:life_track/screens/finances/dialogs/transaction_dialogs.dart';
import 'package:life_track/screens/finances/dialogs/saving_goal_dialogs.dart';
import 'package:life_track/screens/finances/dialogs/recurring_expense_dialogs.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}        

class _FinancesScreenState extends State<FinancesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Finanzas', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cuentas'),
            Tab(text: 'Transacciones'),
            Tab(text: 'Metas de Ahorro'),
            Tab(text: 'Gastos Fijos'),
          ],
          indicatorColor: AppColors.financesPrimary,
          labelColor: AppColors.financesPrimary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AccountsTab(),
          TransactionsTab(),
          SavingGoalsTab(),
          RecurringExpensesTab(),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              switch (_tabController.index) {
                case 0:
                  AccountDialogs.showAddAccountDialog(context);
                  break;
                case 1:
                  TransactionDialogs.showAddTransactionDialog(context);
                  break;
                case 2:
                  SavingGoalDialogs.showAddSavingGoalDialog(context);
                  break;
                case 3:
                  RecurringExpenseDialogs.showAddRecurringExpenseDialog(context);
                  break;
              }
            },
            backgroundColor: AppColors.financesPrimary,
            foregroundColor: Colors.black,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
} 