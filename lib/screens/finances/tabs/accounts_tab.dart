import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:life_track/providers/providers.dart';
import 'package:life_track/screens/finances/widgets/account_card.dart';
import 'package:life_track/screens/finances/dialogs/account_dialogs.dart';
import 'package:life_track/main.dart'; // Importar colores

class AccountsTab extends StatelessWidget {
  const AccountsTab({super.key});

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

        if (provider.accounts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance, size: 80, color: AppColors.financesPrimary.withAlpha(100)),
                const SizedBox(height: 24),
                Text(
                  'No hay cuentas financieras registradas',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir nueva cuenta'),
                  onPressed: () {
                    AccountDialogs.showAddAccountDialog(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.financesPrimary,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.financesPrimary,
                      AppColors.financesPrimary.withBlue(200),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.financesPrimary.withAlpha(90),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Balance Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(provider.totalBalance),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        provider.totalBalance >= 0 ? 'Saldo positivo' : 'Saldo negativo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.credit_card, size: 20, color: AppColors.financesPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Mis Cuentas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.accounts.length} cuentas',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.accounts.length,
                itemBuilder: (context, index) {
                  final account = provider.accounts[index];
                  return AccountCard(
                    account: account,
                    currencyFormat: currencyFormat,
                    onTap: () {
                      AccountDialogs.showAccountDetailsDialog(context, account);
                    },
                    onEdit: () {
                      AccountDialogs.showEditAccountDialog(context, account);
                    },
                    onDelete: () {
                      AccountDialogs.showDeleteAccountConfirmDialog(context, account);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
} 