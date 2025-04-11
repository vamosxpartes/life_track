import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_track/models/transaction.dart' as app_models;

class TransactionCard extends StatelessWidget {
  final app_models.Transaction transaction;
  final String accountName;
  final VoidCallback onTap;
  final NumberFormat currencyFormat;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.accountName,
    required this.onTap,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar color e icono según el tipo de transacción
    Color? color;
    IconData icon;
    
    switch (transaction.type) {
      case app_models.TransactionType.income:
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
      case app_models.TransactionType.expense:
        color = Colors.red;
        icon = Icons.arrow_upward;
        break;
      case app_models.TransactionType.transfer:
        color = Colors.blue;
        icon = Icons.swap_horiz;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(60),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.category + 
          (transaction.subcategory != null ? ' - ${transaction.subcategory}' : ''),
        ),
        subtitle: Text(accountName),
        trailing: Text(
          currencyFormat.format(transaction.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
} 