import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/models/transaction.dart' as app_models;
import 'package:life_track/providers/providers.dart';
import 'package:life_track/screens/finances/dialogs/transaction_dialogs.dart';

class AccountDialogs {
  static void showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    var selectedType = AccountType.bank;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Cuenta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la cuenta',
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(
                  labelText: 'Saldo inicial',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de cuenta',
                  prefixIcon: Icon(Icons.category),
                ),
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
                items: AccountType.values.map((type) {
                  return DropdownMenuItem<AccountType>(
                    value: type,
                    child: Text(_getAccountTypeName(type)),
                  );
                }).toList(),
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
              final name = nameController.text.trim();
              final balanceText = balanceController.text.trim();
              
              if (name.isNotEmpty && balanceText.isNotEmpty) {
                try {
                  final balance = double.parse(balanceText.replaceAll(',', '.'));
                  
                  final account = FinancialAccount(
                    name: name,
                    type: selectedType,
                    balance: balance,
                  );
                  
                  Provider.of<FinancesProvider>(context, listen: false)
                      .addAccount(account);
                  
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor introduce un saldo válido')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor completa todos los campos')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  static void showEditAccountDialog(BuildContext context, FinancialAccount account) {
    final nameController = TextEditingController(text: account.name);
    final balanceController = TextEditingController(text: account.balance.toString());
    var selectedType = account.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Cuenta'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la cuenta',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AccountType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de cuenta',
                      prefixIcon: Icon(Icons.category),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                        });
                      }
                    },
                    items: AccountType.values.map((type) {
                      return DropdownMenuItem<AccountType>(
                        value: type,
                        child: Text(_getAccountTypeName(type)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: balanceController,
                    decoration: const InputDecoration(
                      labelText: 'Saldo actual',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  final name = nameController.text.trim();
                  final balanceText = balanceController.text.trim();
                  
                  if (name.isNotEmpty && balanceText.isNotEmpty) {
                    try {
                      final balance = double.parse(balanceText.replaceAll(',', '.'));
                      
                      final updatedAccount = account.copyWith(
                        name: name,
                        type: selectedType,
                        balance: balance,
                      );
                      
                      Provider.of<FinancesProvider>(context, listen: false)
                          .updateAccount(updatedAccount);
                      
                      Navigator.of(context).pop();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cuenta $name actualizada correctamente')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor introduce un saldo válido')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor completa todos los campos')),
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

  static void showDeleteAccountConfirmDialog(BuildContext context, FinancialAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: Text('¿Estás seguro de eliminar la cuenta "${account.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<FinancesProvider>(context, listen: false)
                  .deleteAccount(account.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cuenta ${account.name} eliminada correctamente')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void showAccountDetailsDialog(BuildContext context, FinancialAccount account) {
    final provider = Provider.of<FinancesProvider>(context, listen: false);
    final dateFormat = DateFormat('dd MMM yyyy', 'es');
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    
    // Obtener transacciones de esta cuenta
    final accountTransactions = provider.transactions
        .where((t) => t.accountId == account.id)
        .toList();
    
    // Ordenar por fecha, las más recientes primero
    accountTransactions.sort((a, b) => b.date.compareTo(a.date));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account.name),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
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
                            Text(_getAccountTypeName(account.type)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Saldo:'),
                            Text(
                              currencyFormat.format(account.balance),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: account.balance >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        if (account.institutionName != null) ...[
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Institución:'),
                              Text(account.institutionName!),
                            ],
                          ),
                        ],
                        if (account.accountNumber != null) ...[
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Número de cuenta:'),
                              Text(account.accountNumber!),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const Text(
                  'Últimas transacciones',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (accountTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay transacciones para esta cuenta'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: accountTransactions.length > 5 
                        ? 5 
                        : accountTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = accountTransactions[index];
                      return ListTile(
                        title: Text(transaction.description ?? 'Sin descripción'),
                        subtitle: Text(dateFormat.format(transaction.date)),
                        trailing: Text(
                          currencyFormat.format(transaction.amount),
                          style: TextStyle(
                            color: transaction.type == app_models.TransactionType.income
                                ? Colors.green
                                : transaction.type == app_models.TransactionType.expense
                                    ? Colors.red
                                    : Colors.blue,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          TransactionDialogs.showTransactionDetailsDialog(context, transaction, account);
                        },
                      );
                    },
                  ),
              ],
            ),
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
              TransactionDialogs.showAddTransactionDialog(context);
            },
            child: const Text('Nueva transacción'),
          ),
        ],
      ),
    );
  }

  static String _getAccountTypeName(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return 'Cuenta Bancaria';
      case AccountType.cash:
        return 'Efectivo';
      case AccountType.digital:
        return 'Billetera Digital';
      case AccountType.investment:
        return 'Inversión';
      case AccountType.other:
        return 'Otra';
    }
  }
} 