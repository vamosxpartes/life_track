import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';
import 'dart:convert';

enum LoanType { given, received }
enum LoanStatus { active, completed, cancelled }

class Loan {
  final String id;
  final String name;
  final String? personName; // Persona a quien prestamos o que nos presta
  final LoanType type; // prestado o recibido
  final double totalAmount; // Monto total del préstamo
  final double remainingAmount; // Monto restante por pagar/cobrar
  final double? interestRate; // Tasa de interés (opcional)
  final DateTime startDate; // Fecha de inicio del préstamo
  final DateTime? dueDate; // Fecha límite de pago (opcional)
  final String? description;
  final List<String> tags;
  final String? accountId; // Cuenta asociada al préstamo
  final LoanStatus status;
  final String? imagePath;

  Loan({
    String? id,
    required this.name,
    this.personName,
    required this.type,
    required this.totalAmount,
    required this.remainingAmount,
    this.interestRate,
    required this.startDate,
    this.dueDate,
    this.description,
    this.tags = const [],
    this.accountId,
    this.status = LoanStatus.active,
    this.imagePath,
  }) : id = id ?? const Uuid().v4();

  factory Loan.fromMap(Map<String, dynamic> map) {
    List<String> parseTags(dynamic tagsData) {
      if (tagsData == null) return [];
      
      try {
        if (tagsData is List) {
          return tagsData.map((e) => e.toString()).toList();
        }
        
        final List<dynamic> decoded = jsonDecode(tagsData);
        return decoded.map((item) => item.toString()).toList();
      } catch (e) {
        developer.log('Error al parsear tags en Loan: $e');
        return [];
      }
    }

    return Loan(
      id: map['id'],
      name: map['name'],
      personName: map['personName'],
      type: LoanType.values.byName(map['type']),
      totalAmount: map['totalAmount'],
      remainingAmount: map['remainingAmount'],
      interestRate: map['interestRate'],
      startDate: DateTime.parse(map['startDate']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      description: map['description'],
      tags: parseTags(map['tags']),
      accountId: map['accountId'],
      status: LoanStatus.values.byName(map['status']),
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'personName': personName,
      'type': type.name,
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
      'interestRate': interestRate,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'description': description,
      'tags': jsonEncode(tags),
      'accountId': accountId,
      'status': status.name,
      'imagePath': imagePath,
    };
  }

  Loan copyWith({
    String? id,
    String? name,
    String? personName,
    LoanType? type,
    double? totalAmount,
    double? remainingAmount,
    double? interestRate,
    DateTime? startDate,
    DateTime? dueDate,
    String? description,
    List<String>? tags,
    String? accountId,
    LoanStatus? status,
    String? imagePath,
  }) {
    return Loan(
      id: id ?? this.id,
      name: name ?? this.name,
      personName: personName ?? this.personName,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      interestRate: interestRate ?? this.interestRate,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      accountId: accountId ?? this.accountId,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
    );
  }
} 