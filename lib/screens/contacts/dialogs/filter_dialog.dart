import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_track/providers/providers.dart';
import 'package:life_track/main.dart'; // Importar colores

void showFilterDialog({
  required BuildContext context,
  required String initialSearchQuery,
  required int? initialMinInterestLevel,
  required int? initialMaxInterestLevel,
  required String? initialSelectedMeetingPlace,
  required Function(String, int?, int?, String?) onApply,
}) {
  String searchQuery = initialSearchQuery;
  int? minInterestLevel = initialMinInterestLevel;
  int? maxInterestLevel = initialMaxInterestLevel;
  String? selectedMeetingPlace = initialSelectedMeetingPlace;

  final commonPlaces = Provider.of<ContactProvider>(context, listen: false)
      .getCommonMeetingPlaces();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filtrar Contactos'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    controller: TextEditingController(text: searchQuery),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 18, color: AppColors.relationsPrimary),
                      const SizedBox(width: 8),
                      const Text(
                        'Nivel de interés:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.relationsPrimary,
                            inactiveTrackColor: AppColors.surface,
                            thumbColor: AppColors.relationsPrimary,
                            overlayColor: AppColors.relationsPrimary.withAlpha(100),
                            rangeThumbShape: const RoundRangeSliderThumbShape(
                              enabledThumbRadius: 8,
                              elevation: 4,
                            ),
                            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                            rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
                            valueIndicatorColor: AppColors.relationsPrimary,
                            valueIndicatorTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: RangeSlider(
                            values: RangeValues(
                              (minInterestLevel ?? 1).toDouble(),
                              (maxInterestLevel ?? 9).toDouble(),
                            ),
                            min: 1,
                            max: 9,
                            divisions: 8,
                            labels: RangeLabels(
                              (minInterestLevel ?? 1).toString(),
                              (maxInterestLevel ?? 9).toString(),
                            ),
                            onChanged: (values) {
                              setState(() {
                                minInterestLevel = values.start.round();
                                maxInterestLevel = values.end.round();
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.relationsPrimary.withAlpha(60),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Mín: ${minInterestLevel ?? 1}',
                                style: TextStyle(
                                  color: AppColors.relationsPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.relationsPrimary.withAlpha(60),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Máx: ${maxInterestLevel ?? 9}',
                                style: TextStyle(
                                  color: AppColors.relationsPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.place, size: 18, color: AppColors.relationsPrimary),
                      const SizedBox(width: 8),
                      const Text(
                        'Lugar de encuentro:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (commonPlaces.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: selectedMeetingPlace,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...commonPlaces.map(
                            (place) => DropdownMenuItem(
                              value: place,
                              child: Text(place),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedMeetingPlace = value;
                          });
                        },
                        underline: const SizedBox(),
                        dropdownColor: AppColors.cardBg,
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('No hay lugares comunes'),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    searchQuery = '';
                    minInterestLevel = null;
                    maxInterestLevel = null;
                    selectedMeetingPlace = null;
                  });
                },
                child: const Text('Limpiar Filtros'),
              ),
              ElevatedButton(
                onPressed: () {
                  onApply(searchQuery, minInterestLevel, maxInterestLevel, selectedMeetingPlace);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.relationsPrimary,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      );
    },
  );
} 