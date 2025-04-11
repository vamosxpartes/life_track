import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';
import 'dart:convert';

enum TransactionType { income, expense, transfer }

class Transaction {
  final String id;
  final String accountId;
  final String? destinationAccountId; // Solo para transferencias
  final DateTime date;
  final double amount;
  final TransactionType type;
  final String category;
  final String? subcategory;
  final String? description;
  final List<String> tags;
  final String? imagePath;
  final bool isRecurring;

  Transaction({
    String? id,
    required this.accountId,
    this.destinationAccountId,
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
    this.subcategory,
    this.description,
    this.tags = const [],
    this.imagePath,
    this.isRecurring = false,
  }) : id = id ?? const Uuid().v4();

  factory Transaction.fromMap(Map<String, dynamic> map) {
    List<String> parseTags(dynamic tagsData) {
      if (tagsData == null) return [];
      
      try {
        // Si ya es una lista de strings, devolverla directamente
        if (tagsData is List) {
          return tagsData.map((e) => e.toString()).toList();
        }
        
        // Intentar decodificar como JSON
        final List<dynamic> decoded = jsonDecode(tagsData);
        return decoded.map((item) => item.toString()).toList();
      } catch (e) {
        developer.log('Error al parsear tags en Transaction: $e');
        return [];
      }
    }

    return Transaction(
      id: map['id'],
      accountId: map['accountId'],
      destinationAccountId: map['destinationAccountId'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      type: TransactionType.values.byName(map['type']),
      category: map['category'],
      subcategory: map['subcategory'],
      description: map['description'],
      tags: parseTags(map['tags']),
      imagePath: map['imagePath'],
      isRecurring: map['isRecurring'] == 1 || map['isRecurring'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'destinationAccountId': destinationAccountId,
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type.name,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'tags': jsonEncode(tags),
      'imagePath': imagePath,
      'isRecurring': isRecurring ? 1 : 0,
    };
  }

  Transaction copyWith({
    String? id,
    String? accountId,
    String? destinationAccountId,
    DateTime? date,
    double? amount,
    TransactionType? type,
    String? category,
    String? subcategory,
    String? description,
    List<String>? tags,
    String? imagePath,
    bool? isRecurring,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      imagePath: imagePath ?? this.imagePath,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
} 