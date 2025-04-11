import 'package:flutter/material.dart';

void showInterestLevelInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Indicadores de Interés'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Según los principios de "The Game" de Neil Strauss y otros libros de seducción:', 
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildInterestLevelDescription(context, 1, 'Ignora completamente, no hay contacto visual'),
            _buildInterestLevelDescription(context, 2, 'Respuestas cortas, lenguaje corporal cerrado'),
            _buildInterestLevelDescription(context, 3, 'Responde pero no inicia conversación'),
            _buildInterestLevelDescription(context, 4, 'Mantiene conversación básica, contacto visual mínimo'),
            _buildInterestLevelDescription(context, 5, 'Sonríe ocasionalmente, muestra algo de interés'),
            _buildInterestLevelDescription(context, 6, 'Hace preguntas personales, busca puntos en común'),
            _buildInterestLevelDescription(context, 7, 'Contacto físico leve, risas frecuentes'),
            _buildInterestLevelDescription(context, 8, 'Proximidad física, busca estar a solas'),
            _buildInterestLevelDescription(context, 9, 'Contacto físico intencional, insinuaciones claras'),
            _buildInterestLevelDescription(context, 10, 'Invitaciones directas, iniciativa clara'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

Widget _buildInterestLevelDescription(BuildContext context, int level, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$level: ', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getInterestLevelColor(level),
          ),
        ),
        Expanded(child: Text(description)),
      ],
    ),
  );
}

Color _getInterestLevelColor(int level) {
  if (level >= 8) return Colors.red;
  if (level >= 6) return Colors.orange;
  if (level >= 4) return Colors.amber;
  return Colors.grey;
} 