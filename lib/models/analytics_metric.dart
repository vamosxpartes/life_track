import 'dart:convert';

enum MetricType {
  habit,
  diary,
  relationship,
  financial,
  combined
}

enum MetricVisualization {
  bar,
  line,
  pie,
  radar,
  progress,
  counter,
  heatmap
}

class AnalyticsMetric {
  final String id;
  final String name;
  final String description;
  final MetricType type;
  final MetricVisualization visualization;
  final Map<String, dynamic> data;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Para gestionar las posiciones en el dashboard
  final int gridRow;
  final int gridColumn;
  final int gridRowSpan;
  final int gridColumnSpan;

  AnalyticsMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.visualization, 
    required this.data,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.gridRow = 0,
    this.gridColumn = 0,
    this.gridRowSpan = 1,
    this.gridColumnSpan = 1,
  });

  // Copia con modificaciones
  AnalyticsMetric copyWith({
    String? id,
    String? name,
    String? description,
    MetricType? type,
    MetricVisualization? visualization,
    Map<String, dynamic>? data,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? gridRow,
    int? gridColumn,
    int? gridRowSpan,
    int? gridColumnSpan,
  }) {
    return AnalyticsMetric(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      visualization: visualization ?? this.visualization,
      data: data ?? this.data,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gridRow: gridRow ?? this.gridRow,
      gridColumn: gridColumn ?? this.gridColumn,
      gridRowSpan: gridRowSpan ?? this.gridRowSpan,
      gridColumnSpan: gridColumnSpan ?? this.gridColumnSpan,
    );
  }

  // Serialización de datos para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'visualization': visualization.toString(),
      'data': jsonEncode(data),
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'gridRow': gridRow,
      'gridColumn': gridColumn,
      'gridRowSpan': gridRowSpan,
      'gridColumnSpan': gridColumnSpan,
    };
  }

  // Deserialización para recuperar datos
  factory AnalyticsMetric.fromJson(Map<String, dynamic> json) {
    return AnalyticsMetric(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: MetricType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MetricType.combined,
      ),
      visualization: MetricVisualization.values.firstWhere(
        (e) => e.toString() == json['visualization'],
        orElse: () => MetricVisualization.counter,
      ),
      data: jsonDecode(json['data']),
      isPinned: json['isPinned'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      gridRow: json['gridRow'] ?? 0,
      gridColumn: json['gridColumn'] ?? 0,
      gridRowSpan: json['gridRowSpan'] ?? 1,
      gridColumnSpan: json['gridColumnSpan'] ?? 1,
    );
  }
}

// Clase para gestionar un KPI personalizado
class CustomKPI {
  final String id;
  final String name;
  final String description;
  final double targetValue;
  final double currentValue;
  final String unit;
  final DateTime targetDate;
  final List<HistoricalValue> historicalValues;

  CustomKPI({
    required this.id,
    required this.name,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.targetDate,
    required this.historicalValues,
  });

  // Calcular el porcentaje de progreso
  double get progressPercentage => (currentValue / targetValue) * 100;

  // Serialización para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'targetDate': targetDate.toIso8601String(),
      'historicalValues': historicalValues.map((e) => e.toJson()).toList(),
    };
  }

  // Deserialización para recuperación
  factory CustomKPI.fromJson(Map<String, dynamic> json) {
    return CustomKPI(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      targetValue: json['targetValue'],
      currentValue: json['currentValue'],
      unit: json['unit'],
      targetDate: DateTime.parse(json['targetDate']),
      historicalValues: (json['historicalValues'] as List)
          .map((e) => HistoricalValue.fromJson(e))
          .toList(),
    );
  }
}

// Registro histórico de un valor
class HistoricalValue {
  final DateTime date;
  final double value;

  HistoricalValue({required this.date, required this.value});

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
    };
  }

  factory HistoricalValue.fromJson(Map<String, dynamic> json) {
    return HistoricalValue(
      date: DateTime.parse(json['date']),
      value: json['value'],
    );
  }
} 