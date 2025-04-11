import 'package:uuid/uuid.dart';

enum RecurrenceFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
  custom
}

class RecurringExpense {
  final String id;
  final String name;
  final String description;
  final double amount;
  final String? accountId;
  final String category;
  final String? subcategory;
  final RecurrenceFrequency frequency;
  final int? customDays; // Para frecuencia personalizada
  final DateTime nextDueDate;
  final int reminderDays; // Días antes para recordatorio
  final bool isActive;
  final String? iconName;
  final String? color;

  RecurringExpense({
    String? id,
    required this.name,
    required this.description,
    required this.amount,
    this.accountId,
    required this.category,
    this.subcategory,
    required this.frequency,
    this.customDays,
    required this.nextDueDate,
    this.reminderDays = 3,
    this.isActive = true,
    this.iconName,
    this.color,
  }) : id = id ?? const Uuid().v4();

  factory RecurringExpense.fromMap(Map<String, dynamic> map) {
    return RecurringExpense(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      amount: map['amount'],
      accountId: map['accountId'],
      category: map['category'],
      subcategory: map['subcategory'],
      frequency: RecurrenceFrequency.values[map['frequency']],
      customDays: map['customDays'],
      nextDueDate: DateTime.parse(map['nextDueDate']),
      reminderDays: map['reminderDays'] ?? 3,
      isActive: map['isActive'] == 1 || map['isActive'] == true,
      iconName: map['iconName'],
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'accountId': accountId,
      'category': category,
      'subcategory': subcategory,
      'frequency': frequency.index,
      'customDays': customDays,
      'nextDueDate': nextDueDate.toIso8601String(),
      'reminderDays': reminderDays,
      'isActive': isActive ? 1 : 0,
      'iconName': iconName,
      'color': color,
    };
  }

  RecurringExpense copyWith({
    String? id,
    String? name,
    String? description,
    double? amount,
    String? accountId,
    String? category,
    String? subcategory,
    RecurrenceFrequency? frequency,
    int? customDays,
    DateTime? nextDueDate,
    int? reminderDays,
    bool? isActive,
    String? iconName,
    String? color,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      reminderDays: reminderDays ?? this.reminderDays,
      isActive: isActive ?? this.isActive,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
    );
  }

  DateTime getNextDueDate() {
    final now = DateTime.now();
    if (nextDueDate.isAfter(now)) {
      return nextDueDate;
    }
    
    DateTime newDate = nextDueDate;
    switch (frequency) {
      case RecurrenceFrequency.daily:
        while (newDate.isBefore(now)) {
          newDate = newDate.add(const Duration(days: 1));
        }
        break;
      case RecurrenceFrequency.weekly:
        while (newDate.isBefore(now)) {
          newDate = newDate.add(const Duration(days: 7));
        }
        break;
      case RecurrenceFrequency.biweekly:
        while (newDate.isBefore(now)) {
          newDate = newDate.add(const Duration(days: 14));
        }
        break;
      case RecurrenceFrequency.monthly:
        while (newDate.isBefore(now)) {
          final month = newDate.month < 12 ? newDate.month + 1 : 1;
          final year = newDate.month < 12 ? newDate.year : newDate.year + 1;
          // Manejar el caso de meses con diferentes días
          final day = newDate.day;
          final daysInMonth = DateTime(year, month + 1, 0).day;
          final adjustedDay = day > daysInMonth ? daysInMonth : day;
          newDate = DateTime(year, month, adjustedDay);
        }
        break;
      case RecurrenceFrequency.quarterly:
        while (newDate.isBefore(now)) {
          final month = (newDate.month + 3 - 1) % 12 + 1;
          final year = newDate.month > 9 ? newDate.year + 1 : newDate.year;
          // Manejar el caso de meses con diferentes días
          final day = newDate.day;
          final daysInMonth = DateTime(year, month + 1, 0).day;
          final adjustedDay = day > daysInMonth ? daysInMonth : day;
          newDate = DateTime(year, month, adjustedDay);
        }
        break;
      case RecurrenceFrequency.yearly:
        while (newDate.isBefore(now)) {
          newDate = DateTime(newDate.year + 1, newDate.month, newDate.day);
        }
        break;
      case RecurrenceFrequency.custom:
        if (customDays != null) {
          while (newDate.isBefore(now)) {
            newDate = newDate.add(Duration(days: customDays!));
          }
        }
        break;
    }
    
    return newDate;
  }

  DateTime getReminderDate() {
    final next = getNextDueDate();
    return next.subtract(Duration(days: reminderDays));
  }

  bool isReminderDue() {
    final now = DateTime.now();
    final reminderDate = getReminderDate();
    return !reminderDate.isAfter(now) && now.isBefore(getNextDueDate());
  }
  
  bool isDue() {
    final now = DateTime.now();
    return !getNextDueDate().isAfter(now.add(const Duration(days: 1)));
  }
} 