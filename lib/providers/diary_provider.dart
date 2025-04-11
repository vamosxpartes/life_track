import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/services/database_service.dart';

class DiaryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<DiaryEntry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DiaryEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEntries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _databaseService.getDiaryEntries();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar las entradas: $e';
      notifyListeners();
    }
  }

  Future<void> addEntry(DiaryEntry entry) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.insertDiaryEntry(entry);
      await loadEntries();
    } catch (e) {
      developer.log('DEBUG: ERROR al crear entrada del diario: $e');
      _isLoading = false;
      _errorMessage = 'Error al añadir la entrada: $e';
      notifyListeners();
    }
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.updateDiaryEntry(entry);
      await loadEntries();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar la entrada: $e';
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.deleteDiaryEntry(id);
      await loadEntries();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar la entrada: $e';
      notifyListeners();
    }
  }

  List<DiaryEntry> searchEntries({
    String? keyword,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _entries.where((entry) {
      bool matchesKeyword = keyword == null ||
          keyword.isEmpty ||
          entry.content.toLowerCase().contains(keyword.toLowerCase());

      bool matchesTags = tags == null ||
          tags.isEmpty ||
          tags.any((tag) => entry.tags.contains(tag));

      bool matchesDateRange = (startDate == null ||
              !entry.date.isBefore(startDate)) &&
          (endDate == null || !entry.date.isAfter(endDate));

      return matchesKeyword && matchesTags && matchesDateRange;
    }).toList();
  }

  List<String> getAllTags() {
    final Set<String> tags = {};
    for (var entry in _entries) {
      tags.addAll(entry.tags);
    }
    return tags.toList()..sort();
  }
} 