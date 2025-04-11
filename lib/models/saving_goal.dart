import 'package:uuid/uuid.dart';

class SavingGoal {
  final String id;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime? targetDate;
  final String? accountId;
  final String? category;
  final String? iconName;
  final String? color;
  final bool isActive;

  SavingGoal({
    String? id,
    required this.name,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.startDate,
    this.targetDate,
    this.accountId,
    this.category,
    this.iconName,
    this.color,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  factory SavingGoal.fromMap(Map<String, dynamic> map) {
    return SavingGoal(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'] ?? 0.0,
      startDate: DateTime.parse(map['startDate']),
      targetDate: map['targetDate'] != null
          ? DateTime.parse(map['targetDate'])
          : null,
      accountId: map['accountId'],
      category: map['category'],
      iconName: map['iconName'],
      color: map['color'],
      isActive: map['isActive'] == 1 || map['isActive'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'accountId': accountId,
      'category': category,
      'iconName': iconName,
      'color': color,
      'isActive': isActive ? 1 : 0,
    };
  }

  SavingGoal copyWith({
    String? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? targetDate,
    String? accountId,
    String? category,
    String? iconName,
    String? color,
    bool? isActive,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
    );
  }

  double getProgressPercentage() {
    return currentAmount / targetAmount;
  }

  bool get isCompleted => currentAmount >= targetAmount;

  int? getDaysRemaining() {
    if (targetDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(targetDate!)) return 0;
    return targetDate!.difference(now).inDays;
  }
} 