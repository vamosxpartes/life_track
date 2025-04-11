import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/providers/providers.dart';

void showAddInteractionDialog(
    BuildContext context, Contact contact, ContactProvider provider) {
  final dateFormat = DateFormat('dd MMM yyyy', 'es');
  final dateController = TextEditingController(
      text: dateFormat.format(DateTime.now()));
  final notesController = TextEditingController();
  final locationController = TextEditingController();
  
  // Valores iniciales
  DateTime selectedDate = DateTime.now();
  InteractionType selectedType = InteractionType.meeting;
  int relationshipProgress = 5;
  
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Nueva Interacción'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<InteractionType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de interacción',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: InteractionType.values.map((type) {
                    String label = '';
                    IconData iconData;
                    
                    switch (type) {
                      case InteractionType.meeting:
                        label = 'En persona';
                        iconData = Icons.people;
                        break;
                      case InteractionType.call:
                        label = 'Llamada telefónica';
                        iconData = Icons.phone;
                        break;
                      case InteractionType.message:
                        label = 'Mensaje';
                        iconData = Icons.message;
                        break;
                      case InteractionType.event:
                        label = 'Evento';
                        iconData = Icons.event;
                        break;
                    }
                    
                    return DropdownMenuItem<InteractionType>(
                      value: type,
                      child: Row(
                        children: [
                          Icon(iconData, size: 18),
                          const SizedBox(width: 8),
                          Text(label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                        dateController.text = dateFormat.format(date);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Lugar',
                    prefixIcon: Icon(Icons.place),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Progreso de la relación:'),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: relationshipProgress.toDouble(),
                        min: 1,
                        max: 9,
                        divisions: 8,
                        label: relationshipProgress.toString(),
                        onChanged: (value) {
                          setState(() {
                            relationshipProgress = value.round();
                          });
                        },
                      ),
                    ),
                    Text('$relationshipProgress'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (notesController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Las notas son obligatorias')),
                  );
                  return;
                }
                
                final interaction = Interaction(
                  contactId: contact.id,
                  date: selectedDate,
                  type: selectedType,
                  location: locationController.text.trim().isNotEmpty 
                      ? locationController.text.trim() 
                      : null,
                  notes: notesController.text.trim(),
                  relationshipProgress: relationshipProgress,
                );
                
                provider.addInteraction(interaction);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    ),
  );
} 