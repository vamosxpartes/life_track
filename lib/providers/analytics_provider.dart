import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:life_track/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AnalyticsProvider extends ChangeNotifier {
  List<AnalyticsMetric> _metrics = [];
  List<CustomKPI> _customKPIs = [];
  bool _isLoading = false;
  
  // Getters
  List<AnalyticsMetric> get metrics => _metrics;
  List<AnalyticsMetric> get pinnedMetrics => _metrics.where((m) => m.isPinned).toList();
  List<CustomKPI> get customKPIs => _customKPIs;
  bool get isLoading => _isLoading;
  
  // Cargar métricas almacenadas
  Future<void> loadMetrics() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar métricas
    final metricsJson = prefs.getStringList('analytics_metrics') ?? [];
    _metrics = metricsJson
        .map((json) => AnalyticsMetric.fromJson(jsonDecode(json)))
        .toList();
    
    // Cargar KPIs personalizados
    final kpisJson = prefs.getStringList('custom_kpis') ?? [];
    _customKPIs = kpisJson
        .map((json) => CustomKPI.fromJson(jsonDecode(json)))
        .toList();
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Guardar métricas
  Future<void> _saveMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    
    final metricsJson = _metrics
        .map((metric) => jsonEncode(metric.toJson()))
        .toList();
    
    await prefs.setStringList('analytics_metrics', metricsJson);
  }
  
  // Guardar KPIs
  Future<void> _saveKPIs() async {
    final prefs = await SharedPreferences.getInstance();
    
    final kpisJson = _customKPIs
        .map((kpi) => jsonEncode(kpi.toJson()))
        .toList();
    
    await prefs.setStringList('custom_kpis', kpisJson);
  }
  
  // Añadir nueva métrica
  Future<void> addMetric(AnalyticsMetric metric) async {
    _metrics.add(metric);
    await _saveMetrics();
    notifyListeners();
  }
  
  // Actualizar una métrica
  Future<void> updateMetric(AnalyticsMetric updatedMetric) async {
    final index = _metrics.indexWhere((m) => m.id == updatedMetric.id);
    
    if (index != -1) {
      _metrics[index] = updatedMetric;
      await _saveMetrics();
      notifyListeners();
    }
  }
  
  // Eliminar una métrica
  Future<void> deleteMetric(String metricId) async {
    _metrics.removeWhere((m) => m.id == metricId);
    await _saveMetrics();
    notifyListeners();
  }
  
  // Fijar/desfijar una métrica en el dashboard
  Future<void> togglePinMetric(String metricId) async {
    final index = _metrics.indexWhere((m) => m.id == metricId);
    
    if (index != -1) {
      final metric = _metrics[index];
      _metrics[index] = metric.copyWith(isPinned: !metric.isPinned);
      await _saveMetrics();
      notifyListeners();
    }
  }
  
  // Actualizar posición de una métrica en el grid
  Future<void> updateMetricPosition(String metricId, int row, int column, 
      [int rowSpan = 1, int columnSpan = 1]) async {
    final index = _metrics.indexWhere((m) => m.id == metricId);
    
    if (index != -1) {
      final metric = _metrics[index];
      _metrics[index] = metric.copyWith(
        gridRow: row,
        gridColumn: column,
        gridRowSpan: rowSpan,
        gridColumnSpan: columnSpan,
      );
      await _saveMetrics();
      notifyListeners();
    }
  }
  
  // Añadir KPI personalizado
  Future<void> addCustomKPI(CustomKPI kpi) async {
    _customKPIs.add(kpi);
    await _saveKPIs();
    notifyListeners();
  }
  
  // Actualizar un KPI
  Future<void> updateCustomKPI(CustomKPI updatedKPI) async {
    final index = _customKPIs.indexWhere((k) => k.id == updatedKPI.id);
    
    if (index != -1) {
      _customKPIs[index] = updatedKPI;
      await _saveKPIs();
      notifyListeners();
    }
  }
  
  // Eliminar un KPI
  Future<void> deleteCustomKPI(String kpiId) async {
    _customKPIs.removeWhere((k) => k.id == kpiId);
    await _saveKPIs();
    notifyListeners();
  }
  
  // Métodos para calcular métricas predefinidas
  
  // Métrica de progreso de hábitos
  Future<AnalyticsMetric> createHabitCompletionMetric() async {
    // Esta función sería implementada para conectar con HabitProvider
    // y calcular estadísticas de completitud de hábitos
    final now = DateTime.now();
    
    return AnalyticsMetric(
      id: const Uuid().v4(),
      name: 'Completitud de Hábitos',
      description: 'Porcentaje de hábitos completados en los últimos 7 días',
      type: MetricType.habit,
      visualization: MetricVisualization.progress,
      data: {
        'percentage': 75.0, // Esto vendría del cálculo real
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      createdAt: now,
      updatedAt: now,
    );
  }
  
  // Métrica de progreso en metas financieras
  Future<AnalyticsMetric> createFinancialGoalsMetric() async {
    // Esta función conectaría con FinancesProvider para obtener datos reales
    final now = DateTime.now();
    
    return AnalyticsMetric(
      id: const Uuid().v4(),
      name: 'Progreso de Metas Financieras',
      description: 'Avance hacia las metas de ahorro',
      type: MetricType.financial,
      visualization: MetricVisualization.bar,
      data: {
        'goals': [
          {'name': 'Meta 1', 'current': 1200, 'target': 5000},
          {'name': 'Meta 2', 'current': 800, 'target': 1000},
        ],
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      createdAt: now,
      updatedAt: now,
    );
  }
  
  // Métrica de interacciones sociales
  Future<AnalyticsMetric> createSocialInteractionsMetric() async {
    // Conectaría con ContactProvider para datos reales
    final now = DateTime.now();
    
    return AnalyticsMetric(
      id: const Uuid().v4(),
      name: 'Interacciones Sociales',
      description: 'Número de interacciones sociales por semana',
      type: MetricType.relationship,
      visualization: MetricVisualization.line,
      data: {
        'weeks': [
          {'week': '1-7 Mayo', 'count': 8},
          {'week': '8-14 Mayo', 'count': 12},
          {'week': '15-21 Mayo', 'count': 5},
          {'week': '22-28 Mayo', 'count': 9},
        ],
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      createdAt: now,
      updatedAt: now,
    );
  }
  
  // Métrica de entradas de diario
  Future<AnalyticsMetric> createDiaryEntriesMetric() async {
    // Conectaría con DiaryProvider
    final now = DateTime.now();
    
    return AnalyticsMetric(
      id: const Uuid().v4(),
      name: 'Entradas de Diario',
      description: 'Número y sentimiento de entradas de diario',
      type: MetricType.diary,
      visualization: MetricVisualization.heatmap,
      data: {
        'entries': [
          {'date': '2023-05-01', 'count': 1, 'sentiment': 0.8},
          {'date': '2023-05-02', 'count': 0, 'sentiment': 0},
          {'date': '2023-05-03', 'count': 2, 'sentiment': 0.3},
          // Más datos...
        ],
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      createdAt: now,
      updatedAt: now,
    );
  }
  
  // Métrica de "nivel de vida" general
  Future<AnalyticsMetric> createLifeLevelMetric() async {
    // Combinaría datos de todos los providers
    final now = DateTime.now();
    
    return AnalyticsMetric(
      id: const Uuid().v4(),
      name: 'Nivel de Vida',
      description: 'Indicador general de progreso personal',
      type: MetricType.combined,
      visualization: MetricVisualization.radar,
      data: {
        'categories': [
          {'name': 'Hábitos', 'score': 7.5},
          {'name': 'Relaciones', 'score': 6.2},
          {'name': 'Finanzas', 'score': 8.1},
          {'name': 'Bienestar', 'score': 7.8},
        ],
        'overallScore': 7.4,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      createdAt: now,
      updatedAt: now,
    );
  }
  
  // Generar todos los informes predefinidos
  Future<void> generateDefaultMetrics() async {
    _isLoading = true;
    notifyListeners();
    
    // Crear métricas predefinidas
    final habitMetric = await createHabitCompletionMetric();
    final financialMetric = await createFinancialGoalsMetric();
    final socialMetric = await createSocialInteractionsMetric();
    final diaryMetric = await createDiaryEntriesMetric();
    final lifeMetric = await createLifeLevelMetric();
    
    // Añadir a la lista y guardar
    _metrics.addAll([
      habitMetric,
      financialMetric,
      socialMetric,
      diaryMetric,
      lifeMetric,
    ]);
    
    await _saveMetrics();
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Generar informe semanal
  Future<Map<String, dynamic>> generateWeeklyReport() async {
    // Aquí se implementaría la lógica para recopilar datos de todos los providers
    // y crear un informe completo semanal
    
    return {
      'dateGenerated': DateTime.now().toIso8601String(),
      'habits': {
        'completed': 15,
        'total': 21,
        'completionRate': 71.4,
        'bestStreak': 5,
      },
      'diary': {
        'entriesCount': 5,
        'averageSentiment': 0.65,
        'keywords': ['trabajo', 'ejercicio', 'familia'],
      },
      'social': {
        'interactions': 8,
        'newContacts': 2,
        'contactsInteractedWith': 5,
      },
      'finances': {
        'income': 1200,
        'expenses': 850,
        'savings': 350,
        'savingsRate': 29.2,
      },
      'lifeLevel': 7.2,
    };
  }
} 