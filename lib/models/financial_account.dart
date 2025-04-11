import 'package:uuid/uuid.dart';

enum AccountType { bank, cash, digital, investment, other }

class FinancialAccount {
  final String id;
  final String name;
  final AccountType type;
  final String? institutionName;
  final double balance;
  final String? accountNumber;
  final String? notes;
  final String? color;
  final bool isActive;

  FinancialAccount({
    String? id,
    required this.name,
    required this.type,
    this.institutionName,
    required this.balance,
    this.accountNumber,
    this.notes,
    this.color,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  factory FinancialAccount.fromMap(Map<String, dynamic> map) {
    return FinancialAccount(
      id: map['id'],
      name: map['name'],
      type: AccountType.values.byName(map['type']),
      institutionName: map['institutionName'],
      balance: map['balance'],
      accountNumber: map['accountNumber'],
      notes: map['notes'],
      color: map['color'],
      isActive: map['isActive'] == 1 || map['isActive'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'institutionName': institutionName,
      'balance': balance,
      'accountNumber': accountNumber,
      'notes': notes,
      'color': color,
      'isActive': isActive ? 1 : 0,
    };
  }

  FinancialAccount copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? institutionName,
    double? balance,
    String? accountNumber,
    String? notes,
    String? color,
    bool? isActive,
  }) {
    return FinancialAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      institutionName: institutionName ?? this.institutionName,
      balance: balance ?? this.balance,
      accountNumber: accountNumber ?? this.accountNumber,
      notes: notes ?? this.notes,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
    );
  }
} 