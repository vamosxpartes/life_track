import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_track/providers/providers.dart';
import 'package:life_track/models/models.dart';
import 'package:intl/intl.dart';
import 'package:life_track/main.dart'; // Importar colores

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'es');
  String _searchQuery = '';
  List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: Consumer<DiaryProvider>(
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

          final entries = _getFilteredEntries(provider);

          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 80, color: AppColors.diaryPrimary.withAlpha(125)),
                  const SizedBox(height: 24),
                  Text(
                    provider.entries.isEmpty
                        ? 'No hay entradas en el diario'
                        : 'No se encontraron entradas con los filtros actuales',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primera entrada'),
                    onPressed: () {
                      _showAddEntryDialog();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.diaryPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildEntryCard(entry);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEntryDialog();
        },
        backgroundColor: AppColors.diaryPrimary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEntryCard(DiaryEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () {
          _showEntryDetailsDialog(entry);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Fecha en formato de chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.diaryPrimary.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.diaryPrimary.withAlpha(90),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppColors.diaryPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _dateFormat.format(entry.date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.diaryPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tags del estado de ánimo
                  if (entry.tags.isNotEmpty)
                    _buildTagChip(entry.tags.first),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.content.length > 150
                    ? '${entry.content.substring(0, 150)}...'
                    : entry.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon: Icons.visibility_outlined,
                    label: 'Ver',
                    onPressed: () {
                      _showEntryDetailsDialog(entry);
                    },
                    color: Colors.grey[700]!,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Editar',
                    onPressed: () {
                      _showEditEntryDialog(entry);
                    },
                    color: AppColors.diaryPrimary,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    label: 'Eliminar',
                    onPressed: () {
                      _showDeleteConfirmDialog(entry);
                    },
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getMoodColor(tag).withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getMoodColor(tag).withAlpha(90),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMoodIcon(tag),
          const SizedBox(width: 6),
          Text(
            tag,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: _getMoodColor(tag),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'feliz':
      case 'alegre':
      case 'contento':
        return Colors.amber;
      case 'triste':
      case 'deprimido':
        return Colors.blue;
      case 'enojado':
      case 'frustrado':
        return Colors.red;
      case 'ansioso':
      case 'preocupado':
        return Colors.purple;
      case 'tranquilo':
      case 'relajado':
        return Colors.green;
      default:
        return AppColors.diaryPrimary;
    }
  }

  Widget _buildMoodIcon(String mood) {
    IconData iconData;

    switch (mood.toLowerCase()) {
      case 'feliz':
        iconData = Icons.sentiment_very_satisfied_rounded;
        break;
      case 'triste':
        iconData = Icons.sentiment_very_dissatisfied_rounded;
        break;
      case 'ansioso':
        iconData = Icons.sentiment_dissatisfied_rounded;
        break;
      case 'relajado':
        iconData = Icons.sentiment_satisfied_rounded;
        break;
      case 'estresado':
        iconData = Icons.sentiment_neutral_rounded;
        break;
      case 'motivado':
        iconData = Icons.sports_score_rounded;
        break;
      case 'cansado':
        iconData = Icons.bedtime_rounded;
        break;
      case 'energético':
        iconData = Icons.bolt_rounded;
        break;
      case 'nostálgico':
        iconData = Icons.hourglass_bottom_rounded;
        break;
      case 'agradecido':
        iconData = Icons.favorite_rounded;
        break;
      default:
        iconData = Icons.mood_rounded;
    }

    return Icon(iconData, color: AppColors.diaryPrimary, size: 22);
  }

  List<DiaryEntry> _getFilteredEntries(DiaryProvider provider) {
    if (_searchQuery.isEmpty && _selectedTags.isEmpty) {
      return provider.entries;
    }

    return provider.searchEntries(
      keyword: _searchQuery.isEmpty ? null : _searchQuery,
      tags: _selectedTags.isEmpty ? null : _selectedTags,
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final allTags = Provider.of<DiaryProvider>(context, listen: false).getAllTags();
        List<String> selectedTags = List.from(_selectedTags);

        return AlertDialog(
          title: const Text('Buscar Entradas'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Palabra clave',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                  },
                  controller: TextEditingController(text: _searchQuery),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Estados de ánimo:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allTags
                      .map(
                        (tag) => FilterChip(
                          label: Text(tag),
                          selected: selectedTags.contains(tag),
                          onSelected: (selected) {
                            if (selected) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          },
                          selectedColor: AppColors.diaryPrimary.withAlpha(60),
                          checkmarkColor: AppColors.diaryPrimary,
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                            color: selectedTags.contains(tag) 
                                ? AppColors.diaryPrimary 
                                : Colors.transparent,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedTags = selectedTags;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.diaryPrimary,
                foregroundColor: Colors.black,
              ),
              child: const Text('Buscar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEntryDialog() {
    final contentController = TextEditingController();
    final List<String> availableMoods = [
      'Feliz', 'Triste', 'Ansioso', 'Relajado', 'Estresado', 
      'Motivado', 'Cansado', 'Energético', 'Nostálgico', 'Agradecido'
    ];
    String selectedMood = availableMoods.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nueva Entrada'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                        labelText: 'Contenido',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: '¿Cómo me siento hoy?',
                        prefixIcon: const Icon(Icons.mood),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      value: selectedMood,
                      items: availableMoods.map((mood) {
                        return DropdownMenuItem<String>(
                          value: mood,
                          child: Row(
                            children: [
                              _buildMoodIcon(mood),
                              const SizedBox(width: 8),
                              Text(mood),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMood = value;
                          });
                        }
                      },
                      dropdownColor: AppColors.cardBg,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final content = contentController.text.trim();
                    if (content.isNotEmpty) {
                      final entry = DiaryEntry(
                        date: DateTime.now(),
                        content: content,
                        tags: [selectedMood],
                      );

                      Provider.of<DiaryProvider>(context, listen: false)
                          .addEntry(entry);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.diaryPrimary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showEditEntryDialog(DiaryEntry entry) {
    final contentController = TextEditingController(text: entry.content);
    final List<String> availableMoods = [
      'Feliz', 'Triste', 'Ansioso', 'Relajado', 'Estresado', 
      'Motivado', 'Cansado', 'Energético', 'Nostálgico', 'Agradecido'
    ];
    
    // Si no hay etiquetas o la etiqueta no está en la lista, selecciona la primera por defecto
    String selectedMood = entry.tags.isNotEmpty && availableMoods.contains(entry.tags.first) 
        ? entry.tags.first 
        : availableMoods.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Entrada'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                        labelText: 'Contenido',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: '¿Cómo me sentí?',
                        prefixIcon: const Icon(Icons.mood),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      value: selectedMood,
                      items: availableMoods.map((mood) {
                        return DropdownMenuItem<String>(
                          value: mood,
                          child: Row(
                            children: [
                              _buildMoodIcon(mood),
                              const SizedBox(width: 8),
                              Text(mood),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMood = value;
                          });
                        }
                      },
                      dropdownColor: AppColors.cardBg,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final content = contentController.text.trim();
                    if (content.isNotEmpty) {
                      final updatedEntry = entry.copyWith(
                        content: content,
                        tags: [selectedMood],
                      );

                      Provider.of<DiaryProvider>(context, listen: false)
                          .updateEntry(updatedEntry);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.diaryPrimary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showEntryDetailsDialog(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_dateFormat.format(entry.date)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entry.tags.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMoodIcon(entry.tags.first),
                        const SizedBox(width: 8),
                        Text(
                          'Estado de ánimo: ${entry.tags.first}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                ],
                Text(
                  entry.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (entry.location != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 20, color: AppColors.diaryPrimary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(entry.location!)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar'),
              onPressed: () {
                Navigator.of(context).pop();
                _showEditEntryDialog(entry);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.diaryPrimary,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Entrada'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: const Text(
              '¿Estás seguro de que deseas eliminar esta entrada? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Eliminar'),
              onPressed: () {
                Provider.of<DiaryProvider>(context, listen: false)
                    .deleteEntry(entry.id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
} 