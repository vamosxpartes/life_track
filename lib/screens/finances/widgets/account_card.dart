import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/main.dart'; // Importar colores

class AccountCard extends StatelessWidget {
  final FinancialAccount account;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final NumberFormat currencyFormat;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    Color balanceColor = account.balance >= 0 ? AppColors.success : AppColors.error;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      account.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getAccountTypeColor(account.type).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAccountTypeIcon(account.type),
                          size: 16,
                          color: _getAccountTypeColor(account.type),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getAccountTypeName(account.type),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getAccountTypeColor(account.type),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (account.institutionName != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      account.institutionName!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      account.balance >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 18,
                      color: balanceColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyFormat.format(account.balance),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: balanceColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.financesPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Eliminar'),
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error.withAlpha(200),
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

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance_rounded;
      case AccountType.cash:
        return Icons.money_rounded;
      case AccountType.digital:
        return Icons.smartphone_rounded;
      case AccountType.investment:
        return Icons.trending_up_rounded;
      case AccountType.other:
        return Icons.account_balance_wallet_rounded;
    }
  }

  String _getAccountTypeName(AccountType type) {
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
  
  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return AppColors.financesPrimary;
      case AccountType.cash:
        return AppColors.success;
      case AccountType.digital:
        return AppColors.relationsPrimary;
      case AccountType.investment:
        return AppColors.diaryPrimary;
      case AccountType.other:
        return Colors.grey;
    }
  }
} 