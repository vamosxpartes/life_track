import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_track/providers/providers.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/main.dart'; // Importar colores

// Importaciones de archivos modularizados
import 'detail/contact_detail_screen.dart';
import 'widgets/contact_card.dart';
import 'dialogs/filter_dialog.dart';
import 'dialogs/add_contact_dialog.dart';
import 'dialogs/delete_confirm_dialog.dart';
import 'dialogs/interest_level_info_dialog.dart';

enum SortOption { nameAsc, nameDesc, interestAsc, interestDesc, recent }

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String _searchQuery = '';
  int? _minInterestLevel;
  int? _maxInterestLevel;
  String? _selectedMeetingPlace;
  bool _showArchived = false;
  SortOption _sortOption = SortOption.interestDesc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Relaciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.visibility_off : Icons.archive),
            tooltip: _showArchived ? 'Ocultar archivados' : 'Mostrar archivados',
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortDialog();
            },
          ),
        ],
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${provider.errorMessage}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          final contacts = _getFilteredAndSortedContacts(provider);

          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 80, color: AppColors.relationsPrimary.withAlpha(125)),
                  const SizedBox(height: 24),
                  Text(
                    provider.contacts.isEmpty
                        ? 'No hay relaciones'
                        : _showArchived 
                            ? 'No hay contactos archivados con estos filtros'
                            : 'No se encontraron relaciones con los filtros actuales',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir nueva relación'),
                    onPressed: () {
                      showAddContactDialog(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.relationsPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 24),
              
              // Carrusel horizontal de contactos
              SizedBox(
                height: 350,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Dismissible(
                      key: Key(contact.id),
                      direction: DismissDirection.vertical,
                      onDismissed: (direction) {
                        if (direction == DismissDirection.up) {
                          _archiveContact(provider, contact.id);
                        } else if (direction == DismissDirection.down) {
                          showDeleteConfirmDialog(context, contact);
                        }
                      },
                      background: Container(
                        color: AppColors.success.withAlpha(200),
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 20),
                        child: const Icon(Icons.archive, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: AppColors.error.withAlpha(200),
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ContactCard(
                        contact: contact,
                        onTap: () => _showContactDetailsScreen(contact),
                        onLongPress: _showInterestLevelInfo,
                        onDelete: () => showDeleteConfirmDialog(context, contact),
                        onArchive: contact.isArchived
                            ? () => _unarchiveContact(provider, contact.id)
                            : () => _archiveContact(provider, contact.id),
                      ),
                    );
                  },
                ),
              ),
              
              // Información adicional
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: AppColors.relationsPrimary),
                          const SizedBox(width: 8),
                          Text(
                            'Información',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nivel de interés del 1 al 10. Mantén presionado para ver más información.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.people, size: 20, color: AppColors.relationsPrimary),
                            const SizedBox(width: 8),
                            Text(
                              'Total: ${contacts.length} contactos',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddContactDialog(context);
        },
        backgroundColor: AppColors.relationsPrimary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Contact> _getFilteredAndSortedContacts(ContactProvider provider) {
    List<Contact> filteredContacts = provider.searchContacts(
      keyword: _searchQuery.isEmpty ? null : _searchQuery,
      minInterestLevel: _minInterestLevel,
      maxInterestLevel: _maxInterestLevel,
      meetingPlace: _selectedMeetingPlace,
      showArchived: _showArchived,
    );
    
    // Aplicar ordenamiento
    switch (_sortOption) {
      case SortOption.nameAsc:
        filteredContacts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        filteredContacts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.interestAsc:
        filteredContacts.sort((a, b) => a.interestLevel.compareTo(b.interestLevel));
        break;
      case SortOption.interestDesc:
        filteredContacts.sort((a, b) => b.interestLevel.compareTo(a.interestLevel));
        break;
      case SortOption.recent:
        filteredContacts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    return filteredContacts;
  }

  void _showFilterDialog() {
    showFilterDialog(
      context: context, 
      initialSearchQuery: _searchQuery,
      initialMinInterestLevel: _minInterestLevel,
      initialMaxInterestLevel: _maxInterestLevel,
      initialSelectedMeetingPlace: _selectedMeetingPlace,
      onApply: (searchQuery, minLevel, maxLevel, meetingPlace) {
        setState(() {
          _searchQuery = searchQuery;
          _minInterestLevel = minLevel;
          _maxInterestLevel = maxLevel;
          _selectedMeetingPlace = meetingPlace;
        });
      }
    );
  }
  
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordenar por'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption(context, SortOption.nameAsc, 'Nombre (A-Z)'),
            _buildSortOption(context, SortOption.nameDesc, 'Nombre (Z-A)'),
            _buildSortOption(context, SortOption.interestAsc, 'Interés (Menor a Mayor)'),
            _buildSortOption(context, SortOption.interestDesc, 'Interés (Mayor a Menor)'),
            _buildSortOption(context, SortOption.recent, 'Más recientes primero'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSortOption(BuildContext context, SortOption option, String title) {
    return RadioListTile<SortOption>(
      title: Text(title),
      value: option,
      groupValue: _sortOption,
      onChanged: (SortOption? value) {
        if (value != null) {
          setState(() {
            _sortOption = value;
          });
          Navigator.pop(context);
        }
      },
      activeColor: AppColors.relationsPrimary,
    );
  }

  void _showInterestLevelInfo() {
    showInterestLevelInfoDialog(context);
  }

  void _showContactDetailsScreen(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailScreen(contact: contact),
      ),
    );
  }

  void _archiveContact(ContactProvider provider, String contactId) {
    provider.archiveContact(contactId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Contacto archivado'),
        backgroundColor: AppColors.cardBg,
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            provider.unarchiveContact(contactId);
          },
          textColor: AppColors.relationsPrimary,
        ),
      ),
    );
  }

  void _unarchiveContact(ContactProvider provider, String contactId) {
    provider.unarchiveContact(contactId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Contacto restaurado'),
        backgroundColor: AppColors.cardBg,
      ),
    );
  }
}