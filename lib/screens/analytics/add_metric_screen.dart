import 'package:flutter/material.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddMetricScreen extends StatefulWidget {
  final AnalyticsMetric? existingMetric;
  
  const AddMetricScreen({super.key, this.existingMetric});

  @override
  State<AddMetricScreen> createState() => _AddMetricScreenState();
}

class _AddMetricScreenState extends State<AddMetricScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late MetricType _type;
  late MetricVisualization _visualization;
  
  // Controladores para los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    
    // Inicializar con valores existentes o valores predeterminados
    _name = widget.existingMetric?.name ?? '';
    _description = widget.existingMetric?.description ?? '';
    _type = widget.existingMetric?.type ?? MetricType.combined;
    _visualization = widget.existingMetric?.visualization ?? MetricVisualization.counter;
    
    _nameController = TextEditingController(text: _name);
    _descriptionController = TextEditingController(text: _description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingMetric == null ? 'Nueva Métrica' : 'Editar Métrica'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre de la métrica
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej: Progreso de Hábitos',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              
              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej: Muestra el porcentaje de hábitos completados',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Tipo de métrica
              const Text(
                'Tipo de Métrica',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MetricType>(
                value: _type,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: MetricType.values.map((type) {
                  return DropdownMenuItem<MetricType>(
                    value: type,
                    child: Text(_getTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Tipo de visualización
              const Text(
                'Tipo de Visualización',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MetricVisualization>(
                value: _visualization,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: MetricVisualization.values.map((viz) {
                  return DropdownMenuItem<MetricVisualization>(
                    value: viz,
                    child: Text(_getVisualizationLabel(viz)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _visualization = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              // En una implementación completa, aquí se añadirían campos específicos
              // según el tipo de visualización seleccionada (datos para gráficos, etc.)
              
              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      widget.existingMetric == null ? 'Crear Métrica' : 'Actualizar Métrica',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final provider = Provider.of<AnalyticsProvider>(context, listen: false);
      final now = DateTime.now();
      
      // Ejemplo básico de datos - en una implementación real
      // estos datos serían más complejos y basados en inputs del usuario
      final dummyData = _getDummyDataForVisualization();
      
      if (widget.existingMetric == null) {
        // Crear nueva métrica
        final newMetric = AnalyticsMetric(
          id: const Uuid().v4(),
          name: _name,
          description: _description,
          type: _type,
          visualization: _visualization,
          data: dummyData,
          createdAt: now,
          updatedAt: now,
        );
        
        provider.addMetric(newMetric);
      } else {
        // Actualizar métrica existente
        final updatedMetric = widget.existingMetric!.copyWith(
          name: _name,
          description: _description,
          type: _type,
          visualization: _visualization,
          data: dummyData,
          updatedAt: now,
        );
        
        provider.updateMetric(updatedMetric);
      }
      
      Navigator.pop(context);
    }
  }
  
  // Obtener etiqueta para el tipo de métrica
  String _getTypeLabel(MetricType type) {
    switch (type) {
      case MetricType.habit:
        return 'Hábitos';
      case MetricType.diary:
        return 'Diario';
      case MetricType.relationship:
        return 'Relaciones';
      case MetricType.financial:
        return 'Finanzas';
      case MetricType.combined:
        return 'Combinado';
      // ignore: unreachable_switch_default
      default:
        return 'Desconocido';
    }
  }
  
  // Obtener etiqueta para el tipo de visualización
  String _getVisualizationLabel(MetricVisualization viz) {
    switch (viz) {
      case MetricVisualization.progress:
        return 'Barra de Progreso';
      case MetricVisualization.counter:
        return 'Contador';
      case MetricVisualization.bar:
        return 'Gráfico de Barras';
      case MetricVisualization.line:
        return 'Gráfico de Líneas';
      case MetricVisualization.pie:
        return 'Gráfico Circular';
      case MetricVisualization.radar:
        return 'Gráfico Radar';
      case MetricVisualization.heatmap:
        return 'Mapa de Calor';
      // ignore: unreachable_switch_default
      default:
        return 'Desconocido';
    }
  }
  
  // Generar datos de ejemplo según el tipo de visualización
  Map<String, dynamic> _getDummyDataForVisualization() {
    // En una implementación real, estos datos vendrían del input del usuario
    // o serían calculados a partir de datos reales de la app
    
    switch (_visualization) {
      case MetricVisualization.progress:
        return {
          'percentage': 65.0,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
      case MetricVisualization.counter:
        return {
          'count': 42,
          'unit': 'veces',
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
      case MetricVisualization.bar:
        return {
          'labels': ['Ene', 'Feb', 'Mar', 'Abr', 'May'],
          'values': [12, 19, 8, 15, 22],
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
      case MetricVisualization.line:
        return {
          'labels': ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'],
          'values': [7, 10, 8, 12],
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
      case MetricVisualization.pie:
        return {
          'segments': [
            {'label': 'Trabajo', 'value': 35},
            {'label': 'Familia', 'value': 25},
            {'label': 'Salud', 'value': 20},
            {'label': 'Ocio', 'value': 20},
          ],
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
      case MetricVisualization.radar:
        return {
          'categories': [
            {'name': 'Hábitos', 'score': 7.5},
            {'name': 'Relaciones', 'score': 6.2},
            {'name': 'Finanzas', 'score': 8.1},
            {'name': 'Bienestar', 'score': 7.8},
          ],
          'overallScore': 7.4,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
      case MetricVisualization.heatmap:
        return {
          'entries': [
            {'date': '2023-05-01', 'count': 1, 'sentiment': 0.8},
            {'date': '2023-05-02', 'count': 0, 'sentiment': 0},
            {'date': '2023-05-03', 'count': 2, 'sentiment': 0.3},
          ],
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
      // ignore: unreachable_switch_default
      default:
        return {
          'value': 0,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
    }
  }
} 