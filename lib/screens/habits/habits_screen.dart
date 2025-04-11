import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_track/providers/providers.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/main.dart'; // Importar colores

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Hábitos', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Diarios'),
            Tab(text: 'Semanales'),
            Tab(text: 'Mensuales'),
          ],
          indicatorColor: AppColors.habitsPrimary,
          labelColor: AppColors.habitsPrimary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body: Consumer<HabitProvider>(
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

          return TabBarView(
            controller: _tabController,
            children: [
              _buildHabitList(provider, FrequencyType.daily),
              _buildHabitList(provider, FrequencyType.weekly),
              _buildHabitList(provider, FrequencyType.monthly),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHabitDialog();
        },
        backgroundColor: AppColors.habitsPrimary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitList(HabitProvider provider, FrequencyType frequency) {
    final habits = provider.getHabitsByFrequency(frequency);

    if (habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: AppColors.habitsPrimary.withAlpha(100)),
            const SizedBox(height: 24),
            Text(
              'No hay hábitos ${_getFrequencyName(frequency).toLowerCase()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Crear nuevo hábito'),
              onPressed: () {
                _showAddHabitDialog();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.habitsPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return _buildHabitCard(habit);
      },
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final today = DateTime.now();
    final isCompletedToday =
        Provider.of<HabitProvider>(context, listen: false)
            .isHabitCompletedOnDate(habit, today);
    final completionRate = habit.getCompletionRate();
    final streak = habit.getCurrentStreak();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () {
          _showHabitDetailsDialog(habit);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox a la izquierda
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: isCompletedToday,
                  onChanged: (value) {
                    if (value ?? false) {
                      Provider.of<HabitProvider>(context, listen: false)
                          .markHabitAsCompleted(habit, today);
                    } else {
                      Provider.of<HabitProvider>(context, listen: false)
                          .unmarkHabitCompletion(habit, today);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  checkColor: Colors.black,
                  activeColor: AppColors.habitsPrimary,
                ),
              ),
              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            habit.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.habitsPrimary.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            _getFrequencyName(habit.frequency),
                            style: TextStyle(
                              color: AppColors.habitsPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        habit.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Estadísticas a la derecha
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatChip(
                    icon: Icons.local_fire_department_rounded,
                    label: '$streak',
                    color: AppColors.diaryPrimary,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    icon: Icons.trending_up_rounded,
                    label: '${(completionRate * 100).toStringAsFixed(0)}%',
                    color: _getCompletionColor(completionRate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 0.8) return AppColors.success;
    if (rate >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  void _showHabitDetailsDialog(Habit habit) {
    final today = DateTime.now();
    final isCompletedToday =
        Provider.of<HabitProvider>(context, listen: false)
            .isHabitCompletedOnDate(habit, today);
    final completionRate = habit.getCompletionRate();
    final streak = habit.getCurrentStreak();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(habit.name),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (habit.description.isNotEmpty) ...[
                  Text(
                    habit.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded, 
                        size: 20, 
                        color: AppColors.habitsPrimary
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Frecuencia: ${_getFrequencyName(habit.frequency)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded, 
                              size: 20, 
                              color: AppColors.diaryPrimary
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Racha actual: $streak',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up_rounded, 
                              size: 20, 
                              color: _getCompletionColor(completionRate)
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(completionRate * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Completado hoy:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: isCompletedToday,
                        onChanged: (value) {
                          if (value) {
                            Provider.of<HabitProvider>(context, listen: false)
                                .markHabitAsCompleted(habit, today);
                          } else {
                            Provider.of<HabitProvider>(context, listen: false)
                                .unmarkHabitCompletion(habit, today);
                          }
                          Navigator.of(context).pop();
                        },
                        activeColor: AppColors.habitsPrimary,
                        activeTrackColor: AppColors.habitsPrimary.withAlpha(125),
                      ),
                    ],
                  ),
                ),
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
                _showEditHabitDialog(habit);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.habitsPrimary,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getFrequencyName(FrequencyType frequency) {
    switch (frequency) {
      case FrequencyType.daily:
        return 'Diario';
      case FrequencyType.weekly:
        return 'Semanal';
      case FrequencyType.monthly:
        return 'Mensual';
    }
  }

  void _showAddHabitDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    FrequencyType selectedFrequency = FrequencyType.daily;
    int goalValue = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nuevo Hábito'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Frecuencia:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<FrequencyType>(
                        value: selectedFrequency,
                        isExpanded: true,
                        items: FrequencyType.values
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(_getFrequencyName(type)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedFrequency = value;
                            });
                          }
                        },
                        underline: const SizedBox(),
                        dropdownColor: AppColors.cardBg,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Meta:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: AppColors.habitsPrimary,
                                thumbColor: AppColors.habitsPrimary,
                                overlayColor: AppColors.habitsPrimary.withAlpha(90),
                              ),
                              child: Slider(
                                value: goalValue.toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: goalValue.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    goalValue = value.round();
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.habitsPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$goalValue',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                    final name = nameController.text.trim();
                    final description = descriptionController.text.trim();
                    if (name.isNotEmpty) {
                      final habit = Habit(
                        name: name,
                        description: description,
                        frequency: selectedFrequency,
                        startDate: DateTime.now(),
                        goal: goalValue,
                      );

                      Provider.of<HabitProvider>(context, listen: false)
                          .addHabit(habit);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.habitsPrimary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditHabitDialog(Habit habit) {
    final nameController = TextEditingController(text: habit.name);
    final descriptionController = TextEditingController(text: habit.description);
    FrequencyType selectedFrequency = habit.frequency;
    int goalValue = habit.goal;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Hábito'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Frecuencia:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<FrequencyType>(
                        value: selectedFrequency,
                        isExpanded: true,
                        items: FrequencyType.values
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(_getFrequencyName(type)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedFrequency = value;
                            });
                          }
                        },
                        underline: const SizedBox(),
                        dropdownColor: AppColors.cardBg,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Meta:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: AppColors.habitsPrimary,
                                thumbColor: AppColors.habitsPrimary,
                                overlayColor: AppColors.habitsPrimary.withAlpha(90),
                              ),
                              child: Slider(
                                value: goalValue.toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: goalValue.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    goalValue = value.round();
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.habitsPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$goalValue',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                    final name = nameController.text.trim();
                    final description = descriptionController.text.trim();
                    if (name.isNotEmpty) {
                      final updatedHabit = habit.copyWith(
                        name: name,
                        description: description,
                        frequency: selectedFrequency,
                        goal: goalValue,
                      );

                      Provider.of<HabitProvider>(context, listen: false)
                          .updateHabit(updatedHabit);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.habitsPrimary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 