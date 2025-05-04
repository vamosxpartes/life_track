import 'package:flutter/material.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/main.dart';

class MetricWidget extends StatelessWidget {
  final AnalyticsMetric metric;
  final bool isEditMode;
  final VoidCallback onEdit;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const MetricWidget({
    super.key,
    required this.metric,
    this.isEditMode = false,
    required this.onEdit,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: metric.isPinned
            ? BorderSide(color: _getTypeColor(metric.type), width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        metric.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isEditMode && metric.isPinned)
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: _getTypeColor(metric.type),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  metric.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildVisualization(context),
                ),
              ],
            ),
          ),
          if (isEditMode)
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón para fijar/desfijar
                  IconButton(
                    icon: Icon(
                      metric.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: _getTypeColor(metric.type),
                    ),
                    iconSize: 20,
                    onPressed: onPin,
                    tooltip: metric.isPinned ? 'Desfijar' : 'Fijar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  // Botón para editar
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    iconSize: 20,
                    onPressed: onEdit,
                    tooltip: 'Editar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  // Botón para eliminar
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    iconSize: 20,
                    onPressed: onDelete,
                    tooltip: 'Eliminar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Construir la visualización según el tipo de métrica
  Widget _buildVisualization(BuildContext context) {
    switch (metric.visualization) {
      case MetricVisualization.progress:
        return _buildProgressVisualization();
      case MetricVisualization.counter:
        return _buildCounterVisualization();
      case MetricVisualization.bar:
        return _buildBarVisualization();
      case MetricVisualization.line:
        return _buildLineVisualization();
      case MetricVisualization.pie:
        return _buildPieVisualization();
      case MetricVisualization.radar:
        return _buildRadarVisualization();
      case MetricVisualization.heatmap:
        return _buildHeatmapVisualization();
      // ignore: unreachable_switch_default
      default:
        return const Center(
          child: Text('Visualización no soportada'),
        );
    }
  }

  // Visualización de progreso (por ejemplo, para completitud de hábitos)
  Widget _buildProgressVisualization() {
    final percentage = (metric.data['percentage'] as double?) ?? 0.0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: percentage / 100,
          minHeight: 8,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(_getTypeColor(metric.type)),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  // Visualización de contador simple
  Widget _buildCounterVisualization() {
    final count = (metric.data['count'] as num?)?.toDouble() ?? 0;
    final unit = metric.data['unit'] as String? ?? '';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toStringAsFixed(count.truncateToDouble() == count ? 0 : 1),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  // Visualización de gráfico de barras (simplificado)
  Widget _buildBarVisualization() {
    // Para simplificar, mostraremos sólo texto indicando que aquí iría un gráfico de barras
    // En una implementación real, se usaría una biblioteca de gráficos como fl_chart
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48),
          SizedBox(height: 8),
          Text('Gráfico de Barras'),
        ],
      ),
    );
  }

  // Visualización de gráfico de líneas (simplificado)
  Widget _buildLineVisualization() {
    // Simplificado para este ejemplo
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 48),
          SizedBox(height: 8),
          Text('Gráfico de Líneas'),
        ],
      ),
    );
  }

  // Visualización de gráfico circular (simplificado)
  Widget _buildPieVisualization() {
    // Simplificado
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart, size: 48),
          SizedBox(height: 8),
          Text('Gráfico Circular'),
        ],
      ),
    );
  }

  // Visualización de gráfico radar (simplificado)
  Widget _buildRadarVisualization() {
    // Simplificado
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, size: 48),
          SizedBox(height: 8),
          Text('Gráfico Radar'),
        ],
      ),
    );
  }

  // Visualización de mapa de calor (simplificado)
  Widget _buildHeatmapVisualization() {
    // Simplificado
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_on, size: 48),
          SizedBox(height: 8),
          Text('Mapa de Calor'),
        ],
      ),
    );
  }

  // Obtener color basado en el tipo de métrica
  Color _getTypeColor(MetricType type) {
    switch (type) {
      case MetricType.habit:
        return AppColors.habitsPrimary;
      case MetricType.diary:
        return AppColors.diaryPrimary;
      case MetricType.relationship:
        return AppColors.relationsPrimary;
      case MetricType.financial:
        return AppColors.financesPrimary;
      case MetricType.combined:
        return Colors.purpleAccent;
      // ignore: unreachable_switch_default
      default:
        return Colors.grey;
    }
  }
} 