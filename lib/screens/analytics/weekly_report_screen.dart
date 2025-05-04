import 'package:flutter/material.dart';
import 'package:life_track/providers/providers.dart';
import 'package:life_track/main.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _reportData = {};
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'es');

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AnalyticsProvider>(context, listen: false);
      final reportData = await provider.generateWeeklyReport();

      setState(() {
        _reportData = reportData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al generar el informe semanal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informe Semanal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir informe',
            onPressed: _shareReport,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _loadReportData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado del informe
                  _buildReportHeader(),
                  const Divider(height: 32),
                  
                  // Resumen general
                  _buildGeneralSummary(),
                  const SizedBox(height: 24),
                  
                  // Detalles por secciones
                  _buildHabitsSection(),
                  const SizedBox(height: 24),
                  
                  _buildDiarySection(),
                  const SizedBox(height: 24),
                  
                  _buildSocialSection(),
                  const SizedBox(height: 24),
                  
                  _buildFinancesSection(),
                  const SizedBox(height: 32),
                  
                  // Sugerencias de mejora
                  _buildSuggestions(),
                ],
              ),
            ),
    );
  }

  // Encabezado del informe con fecha y puntuación general
  Widget _buildReportHeader() {
    final date = DateTime.parse(_reportData['dateGenerated'] as String);
    final lifeLevel = _reportData['lifeLevel'] as double;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informe Semanal',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Generado el ${_dateFormat.format(date)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: _getScoreColor(lifeLevel),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Nivel de Vida',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
              Text(
                lifeLevel.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Resumen general con gráfico
  Widget _buildGeneralSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Aquí iría un gráfico circular o radar con las áreas
            const Center(
              child: Icon(
                Icons.pie_chart,
                size: 100,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Este informe resume tu progreso en todas las áreas de desarrollo personal durante la última semana.',
            ),
          ],
        ),
      ),
    );
  }

  // Sección de hábitos
  Widget _buildHabitsSection() {
    final habits = _reportData['habits'] as Map<String, dynamic>;
    final completed = habits['completed'] as int;
    final total = habits['total'] as int;
    final completionRate = habits['completionRate'] as double;
    final bestStreak = habits['bestStreak'] as int;

    return _buildSectionCard(
      'Hábitos',
      AppColors.habitsPrimary,
      [
        _buildStatRow('Hábitos completados', '$completed/$total'),
        _buildStatRow('Tasa de completitud', '${completionRate.toStringAsFixed(1)}%'),
        _buildStatRow('Mejor racha', '$bestStreak días'),
        // Aquí iría un gráfico de barras horizontales con los hábitos
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Simulación de gráfico de progreso de hábitos',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // Sección del diario
  Widget _buildDiarySection() {
    final diary = _reportData['diary'] as Map<String, dynamic>;
    final entriesCount = diary['entriesCount'] as int;
    final averageSentiment = diary['averageSentiment'] as double;
    final keywords = (diary['keywords'] as List).join(', ');

    return _buildSectionCard(
      'Diario',
      AppColors.diaryPrimary,
      [
        _buildStatRow('Entradas esta semana', '$entriesCount'),
        _buildStatRow('Sentimiento promedio', '${(averageSentiment * 100).toStringAsFixed(0)}% positivo'),
        _buildStatRow('Temas recurrentes', keywords),
      ],
    );
  }

  // Sección social
  Widget _buildSocialSection() {
    final social = _reportData['social'] as Map<String, dynamic>;
    final interactions = social['interactions'] as int;
    final newContacts = social['newContacts'] as int;
    final contactsInteractedWith = social['contactsInteractedWith'] as int;

    return _buildSectionCard(
      'Relaciones',
      AppColors.relationsPrimary,
      [
        _buildStatRow('Interacciones totales', '$interactions'),
        _buildStatRow('Nuevos contactos', '$newContacts'),
        _buildStatRow('Contactos mantenidos', '$contactsInteractedWith'),
      ],
    );
  }

  // Sección de finanzas
  Widget _buildFinancesSection() {
    final finances = _reportData['finances'] as Map<String, dynamic>;
    final income = finances['income'] as int;
    final expenses = finances['expenses'] as int;
    final savings = finances['savings'] as int;
    final savingsRate = finances['savingsRate'] as double;

    return _buildSectionCard(
      'Finanzas',
      AppColors.financesPrimary,
      [
        _buildStatRow('Ingresos', '\$${income.toString()}'),
        _buildStatRow('Gastos', '\$${expenses.toString()}'),
        _buildStatRow('Ahorros', '\$${savings.toString()}'),
        _buildStatRow('Tasa de ahorro', '${savingsRate.toStringAsFixed(1)}%'),
      ],
    );
  }

  // Sección de sugerencias de mejora
  Widget _buildSuggestions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Sugerencias para Mejorar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '• Considera aumentar la frecuencia de meditación para reducir el estrés.',
            ),
            SizedBox(height: 8),
            Text(
              '• Tu tasa de ahorro está por debajo de tu objetivo. Revisa los gastos discrecionales.',
            ),
            SizedBox(height: 8),
            Text(
              '• Has tenido pocas interacciones sociales esta semana. Considera programar alguna actividad grupal.',
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar una fila de estadísticas
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget para construir una tarjeta de sección
  Widget _buildSectionCard(String title, Color color, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withAlpha(100), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  // Obtener un color basado en la puntuación
  Color _getScoreColor(double score) {
    if (score >= 8.0) return const Color(0xFF66BB6A); // Verde
    if (score >= 6.0) return const Color(0xFFFFB74D); // Naranja
    if (score >= 4.0) return const Color(0xFFFFEE58); // Amarillo
    return const Color(0xFFEF5350); // Rojo
  }

  // Compartir el informe
  void _shareReport() {
    final date = DateTime.parse(_reportData['dateGenerated'] as String);
    final formattedDate = _dateFormat.format(date);
    final lifeLevel = _reportData['lifeLevel'] as double;
    
    final habits = _reportData['habits'] as Map<String, dynamic>;
    final diary = _reportData['diary'] as Map<String, dynamic>;
    final social = _reportData['social'] as Map<String, dynamic>;
    final finances = _reportData['finances'] as Map<String, dynamic>;

    // Crear un texto para compartir
    final text = '''
Informe Semanal LifeTrack - $formattedDate

Nivel de Vida: ${lifeLevel.toStringAsFixed(1)}/10

Hábitos:
- Completados: ${habits['completed']}/${habits['total']}
- Tasa de completitud: ${habits['completionRate'].toStringAsFixed(1)}%

Diario:
- Entradas: ${diary['entriesCount']}
- Sentimiento: ${(diary['averageSentiment'] * 100).toStringAsFixed(0)}% positivo

Relaciones:
- Interacciones: ${social['interactions']}
- Nuevos contactos: ${social['newContacts']}

Finanzas:
- Ingresos: \$${finances['income']}
- Gastos: \$${finances['expenses']}
- Ahorros: \$${finances['savings']} (${finances['savingsRate'].toStringAsFixed(1)}%)

Generado con LifeTrack App
''';

    // Compartir el texto
    Share.share(text, subject: 'Mi Informe Semanal LifeTrack');
  }
} 