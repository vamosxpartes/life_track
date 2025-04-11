import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/models/transaction.dart' as app_models;
import 'package:life_track/providers/providers.dart';
import 'package:life_track/screens/finances/widgets/transaction_card.dart';
import 'package:life_track/screens/finances/dialogs/transaction_dialogs.dart';

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

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

        if (provider.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No hay transacciones registradas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        // Agrupación de transacciones por fecha
        final groupedTransactions = <String, List<app_models.Transaction>>{};
        final dateFormat = DateFormat('dd MMM yyyy', 'es');
        
        for (var transaction in provider.transactions) {
          final dateString = dateFormat.format(transaction.date);
          if (!groupedTransactions.containsKey(dateString)) {
            groupedTransactions[dateString] = [];
          }
          groupedTransactions[dateString]!.add(transaction);
        }

        final sortedDates = groupedTransactions.keys.toList()
          ..sort((a, b) => dateFormat.parse(b).compareTo(dateFormat.parse(a)));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final dateString = sortedDates[index];
            final transactions = groupedTransactions[dateString]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    dateString,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ...transactions.map((transaction) {
                  // Buscar el nombre de la cuenta
                  final account = provider.accounts.firstWhere(
                    (a) => a.id == transaction.accountId,
                    orElse: () => FinancialAccount(
                      name: 'Cuenta desconocida',
                      type: AccountType.other,
                      balance: 0,
                    ),
                  );
                  
                  return TransactionCard(
                    transaction: transaction,
                    accountName: account.name,
                    currencyFormat: currencyFormat,
                    onTap: () {
                      TransactionDialogs.showTransactionDetailsDialog(
                        context, 
                        transaction, 
                        account
                      );
                    },
                  );
                }),
                if (index < sortedDates.length - 1) const Divider(),
              ],
            );
          },
        );
      },
    );
  }
} 