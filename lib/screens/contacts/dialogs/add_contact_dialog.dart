import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/providers/providers.dart';

void showAddContactDialog(BuildContext context) {
  final nameController = TextEditingController();
  final occupationController = TextEditingController();
  TextEditingController meetingPlaceController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  int interestLevel = 5;
  
  // Lista de lugares de encuentro
  List<String> meetingPlaces = [];
  
  // Lista para almacenar todos los lugares de encuentro únicos (para autocompletado)
  List<String> allMeetingPlaces = [];
  
  // Obtener todos los lugares de encuentro existentes de todos los contactos
  final provider = Provider.of<ContactProvider>(context, listen: false);
  for (var c in provider.contacts) {
    if (c.meetingPlaces.isNotEmpty) {
      for (var place in c.meetingPlaces) {
        if (!allMeetingPlaces.contains(place)) {
          allMeetingPlaces.add(place);
        }
      }
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nuevo Contacto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: occupationController,
                    decoration: const InputDecoration(
                      labelText: 'Ocupación',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Widget para lugares de encuentro
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lugares de encuentro:'),
                      const SizedBox(height: 8),
                      // Mostrar los lugares seleccionados como chips
                      Wrap(
                        spacing: 8,
                        children: meetingPlaces.map((place) => Chip(
                          label: Text(place),
                          onDeleted: () {
                            setState(() {
                              meetingPlaces.remove(place);
                            });
                          },
                        )).toList(),
                      ),
                      const SizedBox(height: 8),
                      // Campo de texto para agregar nuevos lugares
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return allMeetingPlaces.where((option) => 
                            option.toLowerCase().contains(textEditingValue.text.toLowerCase()) &&
                            !meetingPlaces.contains(option)
                          );
                        },
                        onSelected: (String selection) {
                          setState(() {
                            meetingPlaces.add(selection);
                            meetingPlaceController.clear();
                          });
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          meetingPlaceController = controller;
                          
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Agregar lugar',
                              hintText: 'Escribe para buscar o crear',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  if (controller.text.trim().isNotEmpty) {
                                    setState(() {
                                      meetingPlaces.add(controller.text.trim());
                                      controller.clear();
                                    });
                                  }
                                },
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty && !meetingPlaces.contains(value.trim())) {
                                setState(() {
                                  meetingPlaces.add(value.trim());
                                  controller.clear();
                                });
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  const Text('Nivel de interés:'),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: interestLevel.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: interestLevel.toString(),
                          onChanged: (value) {
                            setState(() {
                              interestLevel = value.round();
                            });
                          },
                        ),
                      ),
                      Text('$interestLevel'),
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
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    final contact = Contact(
                      name: name,
                      occupation: occupationController.text.trim().isNotEmpty
                          ? occupationController.text.trim()
                          : null,
                      meetingPlaces: meetingPlaces,
                      phoneNumber: phoneController.text.trim().isNotEmpty
                          ? phoneController.text.trim()
                          : null,
                      email: emailController.text.trim().isNotEmpty
                          ? emailController.text.trim()
                          : null,
                      interestLevel: interestLevel,
                    );

                    Provider.of<ContactProvider>(context, listen: false)
                        .addContact(contact);
                    Navigator.of(context).pop();
                  }
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