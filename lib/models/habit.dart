import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';
import 'dart:convert';

enum FrequencyType { daily, weekly, monthly }

class Habit {
  final String id;
  final String name;
  final String description;
  final FrequencyType frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final int goal;
  final List<DateTime> completionDates;
  final String? reminderTime;
  final bool isActive;

  Habit({
    String? id,
    required this.name,
    required this.description,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.goal,
    this.completionDates = const [],
    this.reminderTime,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  factory Habit.fromMap(Map<String, dynamic> map) {
    List<DateTime> parseCompletionDates(dynamic datesData) {
      if (datesData == null) return [];
      
      try {
        // Si es un string JSON, decodificarlo
        if (datesData is String) {
          final List<dynamic> decoded = jsonDecode(datesData);
          return decoded.map((date) => DateTime.parse(date.toString())).toList();
        }
        
        // Si ya es una lista
        if (datesData is List) {
          return datesData.map((date) => 
            date is String ? DateTime.parse(date) : DateTime.fromMillisecondsSinceEpoch(0)
          ).toList();
        }
        
        return [];
      } catch (e) {
        developer.log('Error al parsear fechas de completado: $e');
        return [];
      }
    }

    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      frequency: FrequencyType.values.byName(map['frequency']),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      goal: map['goal'],
      completionDates: parseCompletionDates(map['completionDates']),
      reminderTime: map['reminderTime'],
      isActive: map['isActive'] == 1 || map['isActive'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'goal': goal,
      'completionDates': jsonEncode(
          completionDates.map((date) => date.toIso8601String()).toList()),
      'reminderTime': reminderTime,
      'isActive': isActive ? 1 : 0,
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    FrequencyType? frequency,
    DateTime? startDate,
    DateTime? endDate,
    int? goal,
    List<DateTime>? completionDates,
    String? reminderTime,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goal: goal ?? this.goal,
      completionDates: completionDates ?? this.completionDates,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
    );
  }

  double getCompletionRate() {
    if (completionDates.isEmpty) return 0.0;
    
    int totalDays = 0;
    
    final now = DateTime.now();
    DateTime currentDate = startDate;
    
    while (!currentDate.isAfter(now)) {
      if (frequency == FrequencyType.daily) {
        totalDays++;
      } else if (frequency == FrequencyType.weekly && 
                currentDate.weekday == startDate.weekday) {
        totalDays++;
      } else if (frequency == FrequencyType.monthly && 
                currentDate.day == startDate.day) {
        totalDays++;
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return totalDays > 0 ? completionDates.length / totalDays : 0.0;
  }

  int getCurrentStreak() {
    if (completionDates.isEmpty) return 0;
    
    // Ordenar las fechas de finalización
    final sortedDates = [...completionDates]..sort();
    int streak = 1;
    
    // Para hábitos diarios, una racha significa días consecutivos
    if (frequency == FrequencyType.daily) {
      DateTime lastDate = sortedDates.last;
      for (int i = sortedDates.length - 2; i >= 0; i--) {
        final difference = lastDate.difference(sortedDates[i]).inDays;
        if (difference == 1) {
          streak++;
          lastDate = sortedDates[i];
        } else {
          break;
        }
      }
    } else if (frequency == FrequencyType.weekly) {
      // Para hábitos semanales, comprobar semanas consecutivas
      streak = 1;
      // Implementación simplificada
    } else if (frequency == FrequencyType.monthly) {
      // Para hábitos mensuales, comprobar meses consecutivos
      streak = 1;
      // Implementación simplificada
    }
    
    return streak;
  }
} 