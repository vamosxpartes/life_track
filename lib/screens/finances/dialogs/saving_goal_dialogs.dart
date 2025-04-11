import 'package:flutter/material.dart';
import 'package:life_track/models/models.dart';
import 'package:provider/provider.dart';
import 'package:life_track/providers/finances_provider.dart';
import 'package:intl/intl.dart';

class SavingGoalDialogs {
  static void showAddSavingGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetAmountController = TextEditingController();
    final currentAmountController = TextEditingController(text: '0');
    DateTime? targetDate;
    final formKey = GlobalKey<FormState>();
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Meta de Ahorro'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: targetAmountController,
                  decoration: const InputDecoration(labelText: 'Monto Objetivo'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un monto';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Ingresa un monto válido mayor a cero';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: currentAmountController,
                  decoration: const InputDecoration(labelText: 'Monto Actual (opcional)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    targetDate == null
                        ? 'Fecha límite (opcional)'
                        : 'Fecha límite: ${DateFormat('dd/MM/yyyy').format(targetDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      targetDate = date;
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final goal = SavingGoal(
                  name: nameController.text,
                  description: descriptionController.text,
                  targetAmount: double.parse(targetAmountController.text),
                  currentAmount: currentAmountController.text.isEmpty
                      ? 0
                      : double.parse(currentAmountController.text),
                  startDate: DateTime.now(),
                  targetDate: targetDate,
                );
                
                provider.addSavingGoal(goal);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  static void showEditSavingGoalDialog(BuildContext context, SavingGoal goal) {
    final nameController = TextEditingController(text: goal.name);
    final descriptionController = TextEditingController(text: goal.description);
    final targetAmountController = TextEditingController(
        text: goal.targetAmount.toString());
    final currentAmountController = TextEditingController(
        text: goal.currentAmount.toString());
    DateTime? targetDate = goal.targetDate;
    final formKey = GlobalKey<FormState>();
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Meta de Ahorro'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: targetAmountController,
                  decoration: const InputDecoration(labelText: 'Monto Objetivo'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un monto';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Ingresa un monto válido mayor a cero';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: currentAmountController,
                  decoration: const InputDecoration(labelText: 'Monto Actual'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un monto actual';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    targetDate == null
                        ? 'Fecha límite (opcional)'
                        : 'Fecha límite: ${DateFormat('dd/MM/yyyy').format(targetDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: targetDate ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      targetDate = date;
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final updatedGoal = goal.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                  targetAmount: double.parse(targetAmountController.text),
                  currentAmount: double.parse(currentAmountController.text),
                  targetDate: targetDate,
                );
                
                provider.updateSavingGoal(updatedGoal);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  static void showDeleteSavingGoalConfirmDialog(BuildContext context, SavingGoal goal) {
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Meta de Ahorro'),
        content: Text('¿Estás seguro que deseas eliminar la meta "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteSavingGoal(goal.id);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  static void showSavingGoalDetailsDialog(BuildContext context, SavingGoal goal) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    final progress = goal.getProgressPercentage();
    final daysRemaining = goal.getDaysRemaining();
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    final accounts = provider.accounts;
    String? selectedAccountId;
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(goal.description),
              const SizedBox(height: 16),
              Text('Progreso: ${(progress * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 16),
              Text('Meta: ${currencyFormat.format(goal.targetAmount)}'),
              Text('Actual: ${currencyFormat.format(goal.currentAmount)}'),
              Text('Restante: ${currencyFormat.format(goal.targetAmount - goal.currentAmount)}'),
              const SizedBox(height: 16),
              if (daysRemaining != null)
                Text(
                  daysRemaining > 0
                      ? 'Faltan $daysRemaining días para completar'
                      : 'Plazo cumplido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: daysRemaining > 0 ? Colors.blue : Colors.green,
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Agregar a esta meta:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Cuenta de origen'),
                      items: accounts.map((account) {
                        return DropdownMenuItem(
                          value: account.id,
                          child: Text('${account.name} (${currencyFormat.format(account.balance)})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedAccountId = value;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona una cuenta';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Monto a agregar'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un monto';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Ingresa un monto válido mayor a cero';
                        }
                        
                        // Verificar que hay saldo suficiente
                        if (selectedAccountId != null) {
                          final account = accounts.firstWhere((a) => a.id == selectedAccountId);
                          if (amount > account.balance) {
                            return 'Saldo insuficiente en la cuenta';
                          }
                        }
                        
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                provider.addToSavingGoal(goal, amount, selectedAccountId!);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
} 