import 'package:flutter/material.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:life_track/main.dart';
import 'package:life_track/widgets/analytics/metric_widget.dart';
import 'package:life_track/screens/analytics/add_metric_screen.dart';
import 'package:life_track/screens/analytics/weekly_report_screen.dart';
import 'package:uuid/uuid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    
    // Cargar métricas al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
      analyticsProvider.loadMetrics();
      
      // Si no hay métricas, generar las predeterminadas
      if (analyticsProvider.metrics.isEmpty) {
        analyticsProvider.generateDefaultMetrics();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Botón para generar informe semanal
          IconButton(
            icon: const Icon(Icons.summarize),
            tooltip: 'Informe Semanal',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeeklyReportScreen(),
                ),
              );
            },
          ),
          // Botón para alternar modo de edición
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            tooltip: _isEditMode ? 'Finalizar edición' : 'Editar dashboard',
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          final metrics = provider.metrics;
          
          if (metrics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No hay métricas disponibles',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.generateDefaultMetrics();
                    },
                    child: const Text('Generar métricas predeterminadas'),
                  ),
                ],
              ),
            );
          }
          
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomScrollView(
                  slivers: [
                    // Widget para mostrar el nivel de vida general
                    SliverToBoxAdapter(
                      child: _buildLifeLevelWidget(
                        metrics.firstWhere(
                          (m) => m.name == 'Nivel de Vida',
                          orElse: () => metrics.first,
                        ),
                      ),
                    ),
                    
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Métricas destacadas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Grid de métricas fijadas
                    _buildMetricsGrid(
                      provider.pinnedMetrics, 
                      provider, 
                      crossAxisCount: 2,
                    ),
                    
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Todas las métricas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Grid de todas las métricas
                    _buildMetricsGrid(
                      metrics, 
                      provider,
                      crossAxisCount: 1,
                    ),
                  ],
                ),
              ),
              
              // Botones de edición de dashboard solo visibles en modo edición
              if (_isEditMode)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: 'add-kpi',
                        mini: true,
                        backgroundColor: AppColors.habitsPrimary,
                        onPressed: _addCustomKPI,
                        child: const Icon(Icons.trending_up, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'add-metric',
                        backgroundColor: AppColors.diaryPrimary,
                        onPressed: _addMetric,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  // Widget para mostrar el nivel de vida general
  Widget _buildLifeLevelWidget(AnalyticsMetric metric) {
    final data = metric.data;
    final score = data['overallScore'] as double;
    final categories = (data['categories'] as List).cast<Map<String, dynamic>>();
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  metric.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    score.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              metric.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Aquí iría un widget de gráfico radar
            // Por simplicidad, mostraremos los valores como barras
            ...categories.map((category) {
              final name = category['name'] as String;
              final score = category['score'] as double;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: score / 10,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(name),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  // Widget para construir el grid de métricas
  Widget _buildMetricsGrid(
    List<AnalyticsMetric> metrics, 
    AnalyticsProvider provider,
    {required int crossAxisCount}
  ) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final metric = metrics[index];
          return MetricWidget(
            metric: metric,
            isEditMode: _isEditMode,
            onEdit: () => _editMetric(metric),
            onPin: () => provider.togglePinMetric(metric.id),
            onDelete: () => _deleteMetric(metric.id),
          );
        },
        childCount: metrics.length,
      ),
    );
  }
  
  // Obtener un color para el nivel de vida basado en el puntaje
  Color _getScoreColor(double score) {
    if (score >= 8.0) return const Color(0xFF66BB6A); // Verde
    if (score >= 6.0) return const Color(0xFFFFB74D); // Naranja
    if (score >= 4.0) return const Color(0xFFFFEE58); // Amarillo
    return const Color(0xFFEF5350); // Rojo
  }
  
  // Obtener un color por categoría
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hábitos':
        return AppColors.habitsPrimary;
      case 'relaciones':
        return AppColors.relationsPrimary;
      case 'finanzas':
        return AppColors.financesPrimary;
      case 'bienestar':
        return AppColors.diaryPrimary;
      default:
        return Colors.grey;
    }
  }
  
  // Método para añadir una nueva métrica
  void _addMetric() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMetricScreen(),
      ),
    );
  }
  
  // Método para añadir un KPI personalizado
  void _addCustomKPI() {
    // Simple diálogo de creación de KPI
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String description = '';
        double target = 100;
        String unit = '';
        
        return AlertDialog(
          title: const Text('Nuevo KPI'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre del KPI',
                  ),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                  ),
                  onChanged: (value) => description = value,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Valor objetivo',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => target = double.tryParse(value) ?? 100,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Unidad (ej: Km, Kg)',
                  ),
                  onChanged: (value) => unit = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  final provider = Provider.of<AnalyticsProvider>(
                    context, 
                    listen: false,
                  );
                  
                  provider.addCustomKPI(
                    CustomKPI(
                      id: const Uuid().v4(),
                      name: name,
                      description: description,
                      targetValue: target,
                      currentValue: 0,
                      unit: unit,
                      targetDate: DateTime.now().add(const Duration(days: 30)),
                      historicalValues: [],
                    ),
                  );
                  
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
  
  // Método para editar una métrica existente
  void _editMetric(AnalyticsMetric metric) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMetricScreen(
          existingMetric: metric,
        ),
      ),
    );
  }
  
  // Método para eliminar una métrica
  void _deleteMetric(String metricId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar métrica'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta métrica? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              final provider = Provider.of<AnalyticsProvider>(
                context, 
                listen: false,
              );
              
              provider.deleteMetric(metricId);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
} 