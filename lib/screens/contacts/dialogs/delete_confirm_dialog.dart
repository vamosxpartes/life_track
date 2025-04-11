import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/providers/providers.dart';

void showDeleteConfirmDialog(BuildContext context, Contact contact) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Eliminar Contacto'),
        content: Text(
            '¿Estás seguro de que deseas eliminar el contacto "${contact.name}"? Esta acción eliminará también todas sus interacciones y no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ContactProvider>(context, listen: false)
                  .deleteContact(contact.id);
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