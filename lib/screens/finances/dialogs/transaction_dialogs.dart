import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/models/transaction.dart' as app_models;
import 'package:life_track/providers/providers.dart';

class TransactionDialogs {
  static void showAddTransactionDialog(BuildContext context) {
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    if (provider.accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero debes crear una cuenta')),
      );
      return;
    }

    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    var selectedType = app_models.TransactionType.expense;
    var selectedAccountId = provider.accounts.first.id;
    String? selectedDestinationAccountId;
    DateTime selectedDate = DateTime.now();
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nueva Transacción'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<app_models.TransactionType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de transacción',
                      prefixIcon: Icon(Icons.category),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                          selectedDestinationAccountId = null;
                        });
                      }
                    },
                    items: app_models.TransactionType.values.map((type) {
                      return DropdownMenuItem<app_models.TransactionType>(
                        value: type,
                        child: Text(_getTransactionTypeName(type)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedAccountId,
                    decoration: InputDecoration(
                      labelText: selectedType == app_models.TransactionType.transfer
                          ? 'Cuenta de origen'
                          : 'Cuenta',
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedAccountId = value;
                        });
                      }
                    },
                    items: provider.accounts.map((account) {
                      return DropdownMenuItem<String>(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }).toList(),
                  ),
                  if (selectedType == app_models.TransactionType.transfer) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDestinationAccountId,
                      decoration: const InputDecoration(
                        labelText: 'Cuenta de destino',
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      onChanged: (value) {
                        if (value != null && value != selectedAccountId) {
                          setState(() {
                            selectedDestinationAccountId = value;
                          });
                        }
                      },
                      items: provider.accounts
                          .where((account) => account.id != selectedAccountId)
                          .map((account) {
                        return DropdownMenuItem<String>(
                          value: account.id,
                          child: Text(account.name),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(dateFormat.format(selectedDate)),
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
                  final description = descriptionController.text.trim();
                  final amountText = amountController.text.trim();
                  final category = categoryController.text.trim();
                  
                  if (description.isNotEmpty && amountText.isNotEmpty) {
                    try {
                      final amount = double.parse(amountText.replaceAll(',', '.'));
                      
                      if (selectedType == app_models.TransactionType.transfer && 
                          selectedDestinationAccountId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecciona una cuenta de destino')),
                        );
                        return;
                      }
                      
                      final transaction = app_models.Transaction(
                        accountId: selectedAccountId,
                        description: description,
                        amount: amount,
                        date: selectedDate,
                        type: selectedType,
                        category: category.isNotEmpty ? category : "Sin categoría",
                        destinationAccountId: selectedType == app_models.TransactionType.transfer ? 
                            selectedDestinationAccountId : null,
                      );
                      
                      Provider.of<FinancesProvider>(context, listen: false)
                          .addTransaction(transaction);
                      
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor introduce un monto válido')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor completa los campos obligatorios')),
                    );
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

  static void showTransactionDetailsDialog(BuildContext context, app_models.Transaction transaction, FinancialAccount account) {
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    final dateFormat = DateFormat('dd MMM yyyy', 'es');
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    
    // Si es una transferencia, obtener la cuenta destino
    FinancialAccount? destinationAccount;
    if (transaction.type == app_models.TransactionType.transfer && 
        transaction.destinationAccountId != null) {
      try {
        destinationAccount = provider.accounts.firstWhere(
          (a) => a.id == transaction.destinationAccountId
        );
      } catch (e) {
        // La cuenta destino puede no existir
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de Transacción'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tipo:'),
                          Text(_getTransactionTypeName(transaction.type)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Cuenta:'),
                          Text(account.name),
                        ],
                      ),
                      if (destinationAccount != null) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Cuenta destino:'),
                            Text(destinationAccount.name),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fecha:'),
                          Text(dateFormat.format(transaction.date)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Monto:'),
                          Text(
                            currencyFormat.format(transaction.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: transaction.type == app_models.TransactionType.income
                                ? Colors.green
                                : transaction.type == app_models.TransactionType.expense
                                    ? Colors.red
                                    : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Categoría:'),
                          Text(transaction.category),
                        ],
                      ),
                      if (transaction.subcategory != null) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subcategoría:'),
                            Text(transaction.subcategory!),
                          ],
                        ),
                      ],
                      if (transaction.description != null) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Descripción:'),
                            Flexible(
                              child: Text(
                                transaction.description!,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (transaction.tags.isNotEmpty) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Etiquetas:'),
                            Flexible(
                              child: Text(
                                transaction.tags.join(', '),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
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
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar eliminación'),
                  content: const Text(
                    '¿Estás seguro de eliminar esta transacción? Esta acción no se puede deshacer.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.deleteTransaction(transaction.id);
                        Navigator.of(context).pop(); // Cerrar diálogo de confirmación
                        Navigator.of(context).pop(); // Cerrar diálogo de detalles
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transacción eliminada correctamente'),
                          ),
                        );
                      },
                      child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static String _getTransactionTypeName(app_models.TransactionType type) {
    switch (type) {
      case app_models.TransactionType.expense:
        return 'Gasto';
      case app_models.TransactionType.income:
        return 'Ingreso';
      case app_models.TransactionType.transfer:
        return 'Transferencia';
    }
  }
} 