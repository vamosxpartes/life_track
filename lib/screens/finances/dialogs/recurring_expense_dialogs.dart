import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/providers/finances_provider.dart';

class RecurringExpenseDialogs {
  static void showAddRecurringExpenseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final reminderDaysController = TextEditingController(text: '3');
    final customDaysController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    
    RecurrenceFrequency selectedFrequency = RecurrenceFrequency.monthly;
    String? selectedAccountId;
    String selectedCategory = 'Servicios';
    String? selectedSubcategory;
    DateTime nextDueDate = DateTime.now().add(const Duration(days: 1));
    
    // Lista de categorías predefinidas
    final categories = [
      'Servicios',
      'Suscripciones',
      'Vivienda',
      'Transporte',
      'Seguros',
      'Educación',
      'Otros',
    ];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nuevo Gasto Recurrente'),
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
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Monto',
                        prefixText: '\$',
                      ),
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Subcategoría (opcional)',
                      ),
                      onChanged: (value) {
                        selectedSubcategory = value.isEmpty ? null : value;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RecurrenceFrequency>(
                      decoration: const InputDecoration(labelText: 'Frecuencia'),
                      value: selectedFrequency,
                      items: RecurrenceFrequency.values.map((frequency) {
                        String label;
                        switch (frequency) {
                          case RecurrenceFrequency.daily:
                            label = 'Diario';
                            break;
                          case RecurrenceFrequency.weekly:
                            label = 'Semanal';
                            break;
                          case RecurrenceFrequency.biweekly:
                            label = 'Quincenal';
                            break;
                          case RecurrenceFrequency.monthly:
                            label = 'Mensual';
                            break;
                          case RecurrenceFrequency.quarterly:
                            label = 'Trimestral';
                            break;
                          case RecurrenceFrequency.yearly:
                            label = 'Anual';
                            break;
                          case RecurrenceFrequency.custom:
                            label = 'Personalizado';
                            break;
                        }
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedFrequency = value;
                          });
                        }
                      },
                    ),
                    if (selectedFrequency == RecurrenceFrequency.custom)
                      TextFormField(
                        controller: customDaysController,
                        decoration: const InputDecoration(
                          labelText: 'Cada cuántos días',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (selectedFrequency == RecurrenceFrequency.custom) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el número de días';
                            }
                            final days = int.tryParse(value);
                            if (days == null || days <= 0) {
                              return 'Ingresa un número válido mayor a cero';
                            }
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        'Fecha del próximo pago: ${DateFormat('dd/MM/yyyy').format(nextDueDate)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: nextDueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            nextDueDate = date;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      controller: reminderDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Días de anticipación para recordatorio',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa los días de anticipación';
                        }
                        final days = int.tryParse(value);
                        if (days == null || days < 0) {
                          return 'Ingresa un número válido mayor o igual a cero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Cuenta (opcional)'),
                      value: selectedAccountId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Ninguna'),
                        ),
                        ...provider.accounts.map((account) {
                          return DropdownMenuItem(
                            value: account.id,
                            child: Text(account.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedAccountId = value;
                        });
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
                    final expense = RecurringExpense(
                      name: nameController.text,
                      description: descriptionController.text,
                      amount: double.parse(amountController.text),
                      accountId: selectedAccountId,
                      category: selectedCategory,
                      subcategory: selectedSubcategory,
                      frequency: selectedFrequency,
                      customDays: selectedFrequency == RecurrenceFrequency.custom
                          ? int.parse(customDaysController.text)
                          : null,
                      nextDueDate: nextDueDate,
                      reminderDays: int.parse(reminderDaysController.text),
                    );
                    
                    provider.addRecurringExpense(expense);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showEditRecurringExpenseDialog(BuildContext context, RecurringExpense expense) {
    final nameController = TextEditingController(text: expense.name);
    final descriptionController = TextEditingController(text: expense.description);
    final amountController = TextEditingController(text: expense.amount.toString());
    final reminderDaysController = TextEditingController(text: expense.reminderDays.toString());
    final customDaysController = TextEditingController(
        text: expense.customDays?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    
    var selectedFrequency = expense.frequency;
    var selectedAccountId = expense.accountId;
    var selectedCategory = expense.category;
    var selectedSubcategory = expense.subcategory;
    var nextDueDate = expense.nextDueDate;
    
    // Lista de categorías predefinidas
    final categories = [
      'Servicios',
      'Suscripciones',
      'Vivienda',
      'Transporte',
      'Seguros',
      'Educación',
      'Otros',
    ];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Gasto Recurrente'),
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
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Monto',
                        prefixText: '\$',
                      ),
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: selectedSubcategory ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Subcategoría (opcional)',
                      ),
                      onChanged: (value) {
                        selectedSubcategory = value.isEmpty ? null : value;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RecurrenceFrequency>(
                      decoration: const InputDecoration(labelText: 'Frecuencia'),
                      value: selectedFrequency,
                      items: RecurrenceFrequency.values.map((frequency) {
                        String label;
                        switch (frequency) {
                          case RecurrenceFrequency.daily:
                            label = 'Diario';
                            break;
                          case RecurrenceFrequency.weekly:
                            label = 'Semanal';
                            break;
                          case RecurrenceFrequency.biweekly:
                            label = 'Quincenal';
                            break;
                          case RecurrenceFrequency.monthly:
                            label = 'Mensual';
                            break;
                          case RecurrenceFrequency.quarterly:
                            label = 'Trimestral';
                            break;
                          case RecurrenceFrequency.yearly:
                            label = 'Anual';
                            break;
                          case RecurrenceFrequency.custom:
                            label = 'Personalizado';
                            break;
                        }
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedFrequency = value;
                          });
                        }
                      },
                    ),
                    if (selectedFrequency == RecurrenceFrequency.custom)
                      TextFormField(
                        controller: customDaysController,
                        decoration: const InputDecoration(
                          labelText: 'Cada cuántos días',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (selectedFrequency == RecurrenceFrequency.custom) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el número de días';
                            }
                            final days = int.tryParse(value);
                            if (days == null || days <= 0) {
                              return 'Ingresa un número válido mayor a cero';
                            }
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        'Fecha del próximo pago: ${DateFormat('dd/MM/yyyy').format(nextDueDate)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: nextDueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            nextDueDate = date;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      controller: reminderDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Días de anticipación para recordatorio',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa los días de anticipación';
                        }
                        final days = int.tryParse(value);
                        if (days == null || days < 0) {
                          return 'Ingresa un número válido mayor o igual a cero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(labelText: 'Cuenta (opcional)'),
                      value: selectedAccountId,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Ninguna'),
                        ),
                        ...provider.accounts.map((account) {
                          return DropdownMenuItem<String?>(
                            value: account.id,
                            child: Text(account.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedAccountId = value;
                        });
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
                    final updatedExpense = expense.copyWith(
                      name: nameController.text,
                      description: descriptionController.text,
                      amount: double.parse(amountController.text),
                      accountId: selectedAccountId,
                      category: selectedCategory,
                      subcategory: selectedSubcategory,
                      frequency: selectedFrequency,
                      customDays: selectedFrequency == RecurrenceFrequency.custom
                          ? int.parse(customDaysController.text)
                          : null,
                      nextDueDate: nextDueDate,
                      reminderDays: int.parse(reminderDaysController.text),
                    );
                    
                    provider.updateRecurringExpense(updatedExpense);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showDeleteRecurringExpenseDialog(BuildContext context, RecurringExpense expense) {
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto Recurrente'),
        content: Text('¿Estás seguro que deseas eliminar el gasto "${expense.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteRecurringExpense(expense.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  static void showProcessRecurringExpenseDialog(BuildContext context, RecurringExpense expense) {
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    final noteController = TextEditingController();
    
    if (expense.accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este gasto no tiene una cuenta asignada. Por favor edítalo primero.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Obtener la cuenta para mostrar el saldo
    final account = provider.accounts.firstWhere(
      (a) => a.id == expense.accountId,
      orElse: () => FinancialAccount(
        name: 'Desconocida',
        type: AccountType.other,
        balance: 0,
      ),
    );
    
    if (account.balance < expense.amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo insuficiente en la cuenta para realizar este pago.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Pago'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vas a registrar un pago de ${NumberFormat.currency(locale: 'es_CO', symbol: '\$').format(expense.amount)} para "${expense.name}"'),
              const SizedBox(height: 8),
              Text('Cuenta: ${account.name}'),
              Text('Saldo actual: ${NumberFormat.currency(locale: 'es_CO', symbol: '\$').format(account.balance)}'),
              Text('Saldo después del pago: ${NumberFormat.currency(locale: 'es_CO', symbol: '\$').format(account.balance - expense.amount)}'),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  hintText: 'Ej. Pago de junio',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.processRecurringExpense(
                expense,
                note: noteController.text.isEmpty ? null : noteController.text,
              );
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pago registrado: ${expense.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Registrar Pago'),
          ),
        ],
      ),
    );
  }

  static void showSkipRecurringExpenseDialog(BuildContext context, RecurringExpense expense) {
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    final nextDate = expense.getNextDueDate();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Omitir Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro que deseas omitir el pago actual de "${expense.name}"?'),
            const SizedBox(height: 8),
            Text('Fecha actual: ${DateFormat('dd/MM/yyyy').format(expense.nextDueDate)}'),
            Text('Siguiente fecha: ${DateFormat('dd/MM/yyyy').format(nextDate)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.skipRecurringExpense(expense);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pago omitido: ${expense.name}'),
                ),
              );
            },
            child: const Text('Omitir'),
          ),
        ],
      ),
    );
  }
  
  static void showRecurringExpenseDetailsDialog(BuildContext context, RecurringExpense expense) {
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    
    // Determinar la frecuencia en texto
    String frequencyText;
    switch (expense.frequency) {
      case RecurrenceFrequency.daily:
        frequencyText = 'Diario';
        break;
      case RecurrenceFrequency.weekly:
        frequencyText = 'Semanal';
        break;
      case RecurrenceFrequency.biweekly:
        frequencyText = 'Quincenal';
        break;
      case RecurrenceFrequency.monthly:
        frequencyText = 'Mensual';
        break;
      case RecurrenceFrequency.quarterly:
        frequencyText = 'Trimestral';
        break;
      case RecurrenceFrequency.yearly:
        frequencyText = 'Anual';
        break;
      case RecurrenceFrequency.custom:
        frequencyText = 'Personalizado';
        if (expense.customDays != null) {
          frequencyText += ' (cada ${expense.customDays} días)';
        }
        break;
    }
    
    // Cuenta asignada
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
    
    // Próximas 3 fechas de pago
    final nextDates = <DateTime>[];
    DateTime tempDate = expense.nextDueDate;
    for (int i = 0; i < 3; i++) {
      nextDates.add(tempDate);
      
      switch (expense.frequency) {
        case RecurrenceFrequency.daily:
          tempDate = tempDate.add(const Duration(days: 1));
          break;
        case RecurrenceFrequency.weekly:
          tempDate = tempDate.add(const Duration(days: 7));
          break;
        case RecurrenceFrequency.biweekly:
          tempDate = tempDate.add(const Duration(days: 14));
          break;
        case RecurrenceFrequency.monthly:
          final month = tempDate.month < 12 ? tempDate.month + 1 : 1;
          final year = tempDate.month < 12 ? tempDate.year : tempDate.year + 1;
          final day = tempDate.day;
          final daysInMonth = DateTime(year, month + 1, 0).day;
          final adjustedDay = day > daysInMonth ? daysInMonth : day;
          tempDate = DateTime(year, month, adjustedDay);
          break;
        case RecurrenceFrequency.quarterly:
          final month = (tempDate.month + 3 - 1) % 12 + 1;
          final year = tempDate.month > 9 ? tempDate.year + 1 : tempDate.year;
          final day = tempDate.day;
          final daysInMonth = DateTime(year, month + 1, 0).day;
          final adjustedDay = day > daysInMonth ? daysInMonth : day;
          tempDate = DateTime(year, month, adjustedDay);
          break;
        case RecurrenceFrequency.yearly:
          tempDate = DateTime(tempDate.year + 1, tempDate.month, tempDate.day);
          break;
        case RecurrenceFrequency.custom:
          if (expense.customDays != null) {
            tempDate = tempDate.add(Duration(days: expense.customDays!));
          }
          break;
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Descripción: ${expense.description}'),
              const SizedBox(height: 16),
              Text('Monto: ${currencyFormat.format(expense.amount)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Categoría: ${expense.category}'),
              if (expense.subcategory != null) 
                Text('Subcategoría: ${expense.subcategory}'),
              const SizedBox(height: 16),
              Text('Frecuencia: $frequencyText'),
              Text('Cuenta: $accountName'),
              Text('Recordatorio: ${expense.reminderDays} días antes'),
              const SizedBox(height: 16),
              const Text('Próximas fechas de pago:', style: TextStyle(fontWeight: FontWeight.bold)),
              for (var date in nextDates)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• ${DateFormat('dd/MM/yyyy').format(date)}'),
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
              Navigator.of(context).pop();
              showEditRecurringExpenseDialog(context, expense);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
} 