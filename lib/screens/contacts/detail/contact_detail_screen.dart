import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_track/providers/providers.dart';
import 'package:life_track/models/models.dart';
import 'package:intl/intl.dart';

import '../dialogs/edit_contact_dialog.dart';
import '../dialogs/delete_confirm_dialog.dart';
import '../widgets/detail_chip.dart';
import '../dialogs/edit_profile_dialog.dart';
import '../dialogs/add_interaction_dialog.dart';
import '../dialogs/edit_interaction_dialog.dart';
import '../dialogs/delete_interaction_dialog.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'es');

  ContactDetailScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, _) {
          // Verificar si necesitamos cargar las interacciones
          if (provider.getInteractionsForContact(contact.id).isEmpty) {
            // Programar la carga después de que se complete el build actual
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.loadInteractionsForContact(contact.id);
            });
          }
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withAlpha(15),
                  Colors.white,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context),
                  
                  // Sección de Perfil
                  const SizedBox(height: 24),
                  _buildProfileSection(context),
                  
                  // Sección de Interacciones
                  const SizedBox(height: 24),
                  _buildInteractionsSection(context, provider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddInteractionDialog(context, contact, Provider.of<ContactProvider>(context, listen: false));
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Añadir interacción',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Hero(
                    tag: 'avatar-${contact.id}',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primary.withAlpha(50),
                      backgroundImage: contact.photoPath != null
                          ? AssetImage(contact.photoPath!)
                          : null,
                      child: contact.photoPath == null
                          ? Text(
                              contact.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _getInterestLevelColor(contact.interestLevel),
                    child: Text(
                      '${contact.interestLevel}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                contact.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (contact.occupation != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  contact.occupation!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(
                  context,
                  Icons.edit,
                  'Editar',
                  () => showEditContactDialog(context, contact),
                ),
                _buildInfoItem(
                  context,
                  Icons.delete,
                  'Eliminar',
                  () => showDeleteConfirmDialog(context, contact),
                ),
                _buildInfoItem(
                  context,
                  Icons.message,
                  'Mensaje',
                  () {
                    // Funcionalidad para mensajes
                  },
                ),
                _buildInfoItem(
                  context,
                  Icons.call,
                  'Llamar',
                  contact.phoneNumber != null ? () {
                    // Funcionalidad para llamar
                  } : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (contact.meetingPlaces.isNotEmpty) ...[
              _buildInfoRow(
                context,
                Icons.place,
                'Lugares de encuentro: ${contact.meetingPlaces.join(', ')}',
              ),
              const SizedBox(height: 12),
            ],
            if (contact.phoneNumber != null) ...[
              _buildInfoRow(
                context,
                Icons.phone,
                contact.phoneNumber!,
              ),
              const SizedBox(height: 12),
            ],
            if (contact.email != null) ...[
              _buildInfoRow(
                context,
                Icons.email,
                contact.email!,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            Text(
              'Descripción',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                contact.notes ?? 'Sin descripción',
                style: TextStyle(
                  color: contact.notes == null
                      ? Colors.grey
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Perfil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colorScheme.primary,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: colorScheme.primary),
              onPressed: () {
                showEditProfileDialog(context, contact);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado Sentimental
                if (contact.relationshipStatus != null) ...[
                  _buildInfoRow(
                    context,
                    Icons.favorite_border,
                    'Estado: ${contact.relationshipStatus}',
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                ],
                
                // Características Físicas
                Text(
                  'Características Físicas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Mostrar sólo si hay alguna característica física
                if (contact.height != null || 
                    contact.bodyType != null || 
                    contact.eyeColor != null || 
                    contact.hairColor != null ||
                    contact.buttocksSize != null ||
                    contact.breastsSize != null ||
                    contact.waistSize != null) ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (contact.height != null)
                        DetailChip(label: 'Altura: ${contact.height}'),
                      if (contact.bodyType != null)
                        DetailChip(label: 'Contextura: ${contact.bodyType}'),
                      if (contact.eyeColor != null)
                        DetailChip(label: 'Ojos: ${contact.eyeColor}'),
                      if (contact.hairColor != null)
                        DetailChip(label: 'Cabello: ${contact.hairColor}'),
                      if (contact.buttocksSize != null)
                        DetailChip(label: 'Glúteos: ${contact.buttocksSize}'),
                      if (contact.breastsSize != null)
                        DetailChip(label: 'Busto: ${contact.breastsSize}'),
                      if (contact.waistSize != null)
                        DetailChip(label: 'Cintura: ${contact.waistSize}'),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'No hay características físicas registradas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),
                
                // Rasgos de Personalidad
                Text(
                  'Personalidad',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                
                if (contact.personalityTraits.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: contact.personalityTraits.map((trait) => 
                      DetailChip(label: trait)
                    ).toList(),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'No hay rasgos de personalidad registrados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionsSection(BuildContext context, ContactProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interacciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        _buildInteractionsList(context, provider),
      ],
    );
  }

  Widget _buildInteractionsList(BuildContext context, ContactProvider provider) {
    final interactions = provider.getInteractionsForContact(contact.id);
    final colorScheme = Theme.of(context).colorScheme;
    
    if (interactions.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 100,
          child: const Center(
            child: Text(
              'No hay interacciones registradas',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: interactions.length,
      itemBuilder: (context, index) {
        final interaction = interactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _dateFormat.format(interaction.date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          onPressed: () {
                            showEditInteractionDialog(
                                context, contact, interaction, provider);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red.shade400,
                          ),
                          onPressed: () {
                            showDeleteInteractionDialog(
                                context, interaction, provider);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    interaction.notes,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                if (interaction.location != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        interaction.location!,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getInterestLevelColor(int level) {
    if (level >= 8) return Colors.red.shade700;
    if (level >= 6) return Colors.orange.shade700;
    if (level >= 4) return Colors.amber.shade700;
    return Colors.grey.shade700;
  }
} 