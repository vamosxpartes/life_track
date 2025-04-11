import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/services/database_service.dart';

class HabitProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHabits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _habits = await _databaseService.getHabits();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      developer.log('DEBUG: ERROR al cargar hábitos: $e');
      developer.log('DEBUG: Tipo de error: ${e.runtimeType}');
      developer.log('DEBUG: Stack trace:');
      try {
        rethrow; // Forzar un error para obtener el stack trace
      } catch (e, stackTrace) {
        developer.log(stackTrace.toString().split('\n').take(5).join('\n'));
      }
      _isLoading = false;
      _errorMessage = 'Error al cargar los hábitos: $e';
      notifyListeners();
    }
  }

  Future<void> addHabit(Habit habit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.insertHabit(habit);
      await loadHabits();
    } catch (e) {
      developer.log('DEBUG: ERROR al crear hábito: $e');
      _isLoading = false;
      _errorMessage = 'Error al añadir el hábito: $e';
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.updateHabit(habit);
      await loadHabits();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar el hábito: $e';
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.deleteHabit(id);
      await loadHabits();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar el hábito: $e';
      notifyListeners();
    }
  }

  Future<void> markHabitAsCompleted(Habit habit, DateTime date) async {
    try { 
      final completionDates = List<DateTime>.from(habit.completionDates);
      
      // Verificar si la fecha ya existe
      final exists = completionDates.any((d) => isSameDay(d, date));
      
      if (!exists) {
        completionDates.add(date);
        
        final updatedHabit = habit.copyWith(completionDates: completionDates);      
        await updateHabit(updatedHabit);
      } else {
        developer.log('DEBUG: Fecha ya existente, no se realiza actualización');
      }
    } catch (e) {
      developer.log('DEBUG: ERROR al marcar hábito como completado: $e');
      developer.log('DEBUG: Tipo de error: ${e.runtimeType}');
      developer.log('DEBUG: Stack trace:');
      try {
        rethrow; // Forzar un error para obtener el stack trace
      } catch (e, stackTrace) {
        developer.log(stackTrace.toString().split('\n').take(5).join('\n'));
      }
      rethrow;
    }
  }
  
  Future<void> unmarkHabitCompletion(Habit habit, DateTime date) async {
    final completionDates = habit.completionDates
        .where((d) => !isSameDay(d, date))
        .toList();
    
    final updatedHabit = habit.copyWith(completionDates: completionDates);
    await updateHabit(updatedHabit);
  }
  
  bool isHabitCompletedOnDate(Habit habit, DateTime date) {
    return habit.completionDates.any((d) => isSameDay(d, date));
  }
  
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  List<Habit> getActiveHabits() {
    return _habits.where((habit) => habit.isActive).toList();
  }
  
  List<Habit> getHabitsByFrequency(FrequencyType frequency) {
    return _habits.where((habit) => 
      habit.isActive && habit.frequency == frequency).toList();
  }
} 