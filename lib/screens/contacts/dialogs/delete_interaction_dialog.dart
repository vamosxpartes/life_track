import 'package:flutter/material.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/providers/providers.dart';

void showDeleteInteractionDialog(
    BuildContext context, Interaction interaction, ContactProvider provider) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Eliminar Interacción'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar esta interacción? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteInteraction(interaction.id, interaction.contactId);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );
} 