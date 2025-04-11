import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/providers/providers.dart';
import 'package:life_track/screens/finances/dialogs/recurring_expense_dialogs.dart';
import 'package:life_track/main.dart'; // Importar los colores

class RecurringExpensesTab extends StatelessWidget {
  const RecurringExpensesTab({super.key});

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

        final activeExpenses = provider.activeRecurringExpenses;
        
        if (activeExpenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 80, color: AppColors.financesPrimary.withAlpha(125)),
                const SizedBox(height: 24),
                Text(
                  'No hay gastos recurrentes registrados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Añade tus gastos fijos mensuales para un mejor control',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir gasto recurrente'),
                  onPressed: () {
                    RecurringExpenseDialogs.showAddRecurringExpenseDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.financesPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Ordenar gastos por fecha de próximo pago
        final sortedExpenses = [...activeExpenses]
          ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
        
        // Separar gastos por vencimiento
        final dueNow = sortedExpenses.where((e) => e.isDue()).toList();
        final upcoming = sortedExpenses.where((e) => !e.isDue()).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (dueNow.isNotEmpty) ...[
              _buildSectionHeader(context, 'Pagos pendientes', AppColors.error),
              const SizedBox(height: 12),
              ...dueNow.map((expense) => _buildExpenseCard(
                context, 
                expense, 
                currencyFormat,
                isOverdue: true,
              )),
              const SizedBox(height: 24),
            ],
            
            _buildSectionHeader(context, 'Próximos pagos', AppColors.financesPrimary),
            const SizedBox(height: 12),
            if (upcoming.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No hay pagos próximos',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              )
            else
              ...upcoming.map((expense) => _buildExpenseCard(
                context, 
                expense, 
                currencyFormat,
              )),
            
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(
    BuildContext context, 
    RecurringExpense expense, 
    NumberFormat currencyFormat, 
    {bool isOverdue = false}
  ) {
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    final daysUntilDue = expense.nextDueDate.difference(DateTime.now()).inDays;
    
    // Determinar el color según la proximidad de la fecha
    Color statusColor;
    if (isOverdue) {
      statusColor = AppColors.error;
    } else if (daysUntilDue <= 3) {
      statusColor = AppColors.warning;
    } else if (daysUntilDue <= 7) {
      statusColor = AppColors.warning.withAlpha(180);
    } else {
      statusColor = AppColors.success;
    }
    
    // Formatear texto de próximo pago
    String dueText;
    if (isOverdue) {
      dueText = 'Vencido';
    } else if (daysUntilDue == 0) {
      dueText = 'Hoy';
    } else if (daysUntilDue == 1) {
      dueText = 'Mañana';
    } else {
      dueText = 'En $daysUntilDue días';
    }
    
    // Cuenta asignada para el pago
    String accountName = 'Sin cuenta asignada';
    if (expense.accountId != null) {
      final account = provider.accounts.firstWhere(
        (a) => a.id == expense.accountId,
        orElse: () => FinancialAccount(
          name: 'Desconocida',
          type: AccountType.other,
          balance: 0,
        ),
      );
      accountName = account.name;
    }
    
    // Determinar el icono basándose en la frecuencia
    IconData frequencyIcon;
    String frequencyText;
    
    switch (expense.frequency) {
      case RecurrenceFrequency.daily:
        frequencyIcon = Icons.today;
        frequencyText = 'Diario';
        break;
      case RecurrenceFrequency.weekly:
        frequencyIcon = Icons.view_week;
        frequencyText = 'Semanal';
        break;
      case RecurrenceFrequency.biweekly:
        frequencyIcon = Icons.date_range;
        frequencyText = 'Quincenal';
        break;
      case RecurrenceFrequency.monthly:
        frequencyIcon = Icons.calendar_month;
        frequencyText = 'Mensual';
        break;
      case RecurrenceFrequency.quarterly:
        frequencyIcon = Icons.calendar_view_month;
        frequencyText = 'Trimestral';
        break;
      case RecurrenceFrequency.yearly:
        frequencyIcon = Icons.calendar_today;
        frequencyText = 'Anual';
        break;
      case RecurrenceFrequency.custom:
        frequencyIcon = Icons.calendar_view_day;
        frequencyText = 'Personalizado';
        if (expense.customDays != null) {
          frequencyText += ' (${expense.customDays} días)';
        }
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isOverdue 
            ? BorderSide(color: AppColors.error.withAlpha(125), width: 1)
            : BorderSide.none,
      ),
      elevation: 0,
      child: InkWell(
        onTap: () {
          RecurringExpenseDialogs.showRecurringExpenseDetailsDialog(context, expense);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      expense.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dueText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_money, size: 16, color: AppColors.financesPrimary),
                    const SizedBox(width: 4),
                    Text(
                      currencyFormat.format(expense.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.financesPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(frequencyIcon, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    frequencyText,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.account_balance, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      accountName,
                      style: TextStyle(color: Colors.grey[400]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    'Próximo pago: ${DateFormat('dd/MM/yyyy').format(expense.nextDueDate)}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey[800], height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Pagar'),
                    onPressed: () {
                      RecurringExpenseDialogs.showProcessRecurringExpenseDialog(context, expense);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.skip_next, size: 18),
                    label: const Text('Omitir'),
                    onPressed: () {
                      RecurringExpenseDialogs.showSkipRecurringExpenseDialog(context, expense);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () {
                        _showOptionsMenu(context, expense);
                      },
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, RecurringExpense expense) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.financesPrimary),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  RecurringExpenseDialogs.showEditRecurringExpenseDialog(context, expense);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: const Text('Eliminar'),
                onTap: () {
                  Navigator.pop(context);
                  RecurringExpenseDialogs.showDeleteRecurringExpenseDialog(context, expense);
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: AppColors.financesPrimary),
                title: const Text('Ver detalles'),
                onTap: () {
                  Navigator.pop(context);
                  RecurringExpenseDialogs.showRecurringExpenseDetailsDialog(context, expense);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
} 