import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/providers/providers.dart';

void showEditProfileDialog(BuildContext context, Contact contact) {
  // Controladores de texto para campos que siguen siendo de entrada de texto
  final heightController = TextEditingController(text: contact.height);
  final waistSizeController = TextEditingController(text: contact.waistSize);
  final personalityController = TextEditingController();
  
  // Opciones para los dropdowns (de más comunes a menos comunes)
  final bodyTypeOptions = ['Delgada', 'Atlética', 'Promedio', 'Curvilínea', 'Robusta', 'Voluptuosa', 'Otro'];
  final eyeColorOptions = ['Marrón', 'Negro', 'Azul', 'Verde', 'Avellana', 'Gris', 'Ámbar', 'Otro'];
  final hairColorOptions = ['Negro', 'Castaño', 'Rubio', 'Pelirrojo', 'Castaño claro', 'Castaño oscuro', 'Gris', 'Otro'];
  final buttocksSizeOptions = ['Pequeño', 'Mediano', 'Grande', 'Muy grande', 'Otro'];
  final breastsSizeOptions = ['Copa A', 'Copa B', 'Copa C', 'Copa D', 'Copa DD', 'Copa E', 'Copa F', 'Copa G', 'Otro'];
  final relationshipStatusOptions = ['Soltera', 'Con novio', 'Casada', 'Divorciada', 'Separada', 'Viuda', 'Relación abierta', 'Es complicado', 'Otro'];
  
  // Valores iniciales para los dropdowns - verificar que existan en las listas de opciones
  String? selectedBodyType = bodyTypeOptions.contains(contact.bodyType) ? contact.bodyType : null;
  String? selectedEyeColor = eyeColorOptions.contains(contact.eyeColor) ? contact.eyeColor : null;
  String? selectedHairColor = hairColorOptions.contains(contact.hairColor) ? contact.hairColor : null;
  String? selectedButtocksSize = buttocksSizeOptions.contains(contact.buttocksSize) ? contact.buttocksSize : null;
  String? selectedBreastsSize = breastsSizeOptions.contains(contact.breastsSize) ? contact.breastsSize : null;
  String? selectedRelationshipStatus = relationshipStatusOptions.contains(contact.relationshipStatus) ? contact.relationshipStatus : null;
  
  // Lista de rasgos de personalidad
  List<String> personalityTraits = List.from(contact.personalityTraits);
  
  // Sugerencias comunes para rasgos de personalidad
  final commonPersonalityTraits = [
    'Amable', 'Extrovertida', 'Introvertida', 'Tímida', 'Sociable', 'Alegre', 'Seria', 
    'Empática', 'Analítica', 'Creativa', 'Ordenada', 'Caótica', 'Puntual', 
    'Responsable', 'Impulsiva', 'Perfeccionista', 'Relajada', 'Dominante', 'Sumisa'
  ];
  
  // Filtrar las sugerencias para no mostrar las que ya están seleccionadas
  List<String> filteredTraits = commonPersonalityTraits
      .where((trait) => !personalityTraits.contains(trait))
      .toList();
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Perfil'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado Sentimental',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: selectedRelationshipStatus,
                    decoration: const InputDecoration(
                      labelText: 'Estado sentimental',
                      hintText: 'Selecciona un estado',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No seleccionado'),
                      ),
                      ...relationshipStatusOptions.map((status) => 
                        DropdownMenuItem<String?>(
                          value: status,
                          child: Text(status),
                        )
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRelationshipStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Características Físicas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: heightController,
                    decoration: const InputDecoration(
                      labelText: 'Altura',
                      hintText: 'Ej. 1.65m',
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: selectedBodyType,
                    decoration: const InputDecoration(
                      labelText: 'Contextura',
                      hintText: 'Selecciona una contextura',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No seleccionado'),
                      ),
                      ...bodyTypeOptions.map((type) => 
                        DropdownMenuItem<String?>(
                          value: type,
                          child: Text(type),
                        )
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedBodyType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: selectedEyeColor,
                    decoration: const InputDecoration(
                      labelText: 'Color de ojos',
                      hintText: 'Selecciona un color',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No seleccionado'),
                      ),
                      ...eyeColorOptions.map((color) => 
                        DropdownMenuItem<String?>(
                          value: color,
                          child: Text(color),
                        )
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedEyeColor = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: selectedHairColor,
                    decoration: const InputDecoration(
                      labelText: 'Color de cabello',
                      hintText: 'Selecciona un color',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No seleccionado'),
                      ),
                      ...hairColorOptions.map((color) => 
                        DropdownMenuItem<String?>(
                          value: color,
                          child: Text(color),
                        )
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedHairColor = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: selectedButtocksSize,
                    decoration: const InputDecoration(
                      labelText: 'Tamaño de glúteos',
                      hintText: 'Selecciona un tamaño',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No seleccionado'),
                      ),
                      ...buttocksSizeOptions.map((size) => 
                        DropdownMenuItem<String?>(
                          value: size,
                          child: Text(size),
                        )
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedButtocksSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: selectedBreastsSize,
                    decoration: const InputDecoration(
                      labelText: 'Tamaño de busto',
                      hintText: 'Selecciona un tamaño',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No seleccionado'),
                      ),
                      ...breastsSizeOptions.map((size) => 
                        DropdownMenuItem<String?>(
                          value: size,
                          child: Text(size),
                        )
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedBreastsSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: waistSizeController,
                    decoration: const InputDecoration(
                      labelText: 'Cintura',
                      hintText: 'Ej. 60cm, Estrecha, etc.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Rasgos de Personalidad',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Mostrar los rasgos seleccionados como chips
                  Wrap(
                    spacing: 8,
                    children: personalityTraits.map((trait) => Chip(
                      label: Text(trait),
                      onDeleted: () {
                        setState(() {
                          personalityTraits.remove(trait);
                          // Añadir de nuevo a las sugerencias
                          if (commonPersonalityTraits.contains(trait) && 
                              !filteredTraits.contains(trait)) {
                            filteredTraits.add(trait);
                            // Ordenar las sugerencias
                            filteredTraits.sort((a, b) => 
                              commonPersonalityTraits.indexOf(a) - 
                              commonPersonalityTraits.indexOf(b));
                          }
                        });
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  
                  // Mostrar sugerencias como chips
                  const Text('Sugerencias:'),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: filteredTraits.map((trait) => 
                      ActionChip(
                        label: Text(trait),
                        onPressed: () {
                          setState(() {
                            personalityTraits.add(trait);
                            filteredTraits.remove(trait);
                          });
                        },
                      )
                    ).toList(),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Campo para agregar rasgos personalizados
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: personalityController,
                          decoration: const InputDecoration(
                            labelText: 'Rasgo personalizado',
                            hintText: 'Ej. Leal, Aventurera, etc.',
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty && !personalityTraits.contains(value.trim())) {
                              setState(() {
                                personalityTraits.add(value.trim());
                                personalityController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (personalityController.text.trim().isNotEmpty && 
                              !personalityTraits.contains(personalityController.text.trim())) {
                            setState(() {
                              personalityTraits.add(personalityController.text.trim());
                              personalityController.clear();
                            });
                          }
                        },
                      ),
                    ],
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
              TextButton(
                onPressed: () {
                  final updatedContact = contact.copyWith(
                    height: heightController.text.trim().isNotEmpty 
                        ? heightController.text.trim() 
                        : null,
                    bodyType: selectedBodyType,
                    eyeColor: selectedEyeColor,
                    hairColor: selectedHairColor,
                    buttocksSize: selectedButtocksSize,
                    breastsSize: selectedBreastsSize,
                    waistSize: waistSizeController.text.trim().isNotEmpty 
                        ? waistSizeController.text.trim() 
                        : null,
                    relationshipStatus: selectedRelationshipStatus,
                    personalityTraits: personalityTraits,
                  );
                  
                  Provider.of<ContactProvider>(context, listen: false)
                      .updateContact(updatedContact);
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil actualizado correctamente')),
                  );
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
} 