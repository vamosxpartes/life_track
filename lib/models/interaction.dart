import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';
import 'dart:convert';

enum InteractionType { meeting, call, message, event }

class Interaction {
  final String id;
  final String contactId;
  final DateTime date;
  final InteractionType type;
  final String? location;
  final String notes;
  final List<String> topics;
  final int relationshipProgress; // 1-9
  final List<String> imagePaths;

  Interaction({
    String? id,
    required this.contactId,
    required this.date,
    required this.type,
    this.location,
    required this.notes,
    this.topics = const [],
    this.relationshipProgress = 5,
    this.imagePaths = const [],
  }) : id = id ?? const Uuid().v4();

  factory Interaction.fromMap(Map<String, dynamic> map) {
    List<String> parseStringList(dynamic listData) {
      if (listData == null) return [];
      
      try {
        // Si ya es una lista de strings, devolverla directamente
        if (listData is List) {
          return listData.map((e) => e.toString()).toList();
        }
        
        // Intentar decodificar como JSON
        final List<dynamic> decoded = jsonDecode(listData);
        return decoded.map((item) => item.toString()).toList();
      } catch (e) {
        developer.log('Error al parsear lista: $e');
        return [];
      }
    }

    return Interaction(
      id: map['id'],
      contactId: map['contactId'],
      date: DateTime.parse(map['date']),
      type: InteractionType.values.byName(map['type']),
      location: map['location'],
      notes: map['notes'],
      topics: parseStringList(map['topics']),
      relationshipProgress: map['relationshipProgress'] ?? 5,
      imagePaths: parseStringList(map['imagePaths']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'date': date.toIso8601String(),
      'type': type.name,
      'location': location,
      'notes': notes,
      'topics': jsonEncode(topics),
      'relationshipProgress': relationshipProgress,
      'imagePaths': jsonEncode(imagePaths),
    };
  }

  Interaction copyWith({
    String? id,
    String? contactId,
    DateTime? date,
    InteractionType? type,
    String? location,
    String? notes,
    List<String>? topics,
    int? relationshipProgress,
    List<String>? imagePaths,
  }) {
    return Interaction(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      date: date ?? this.date,
      type: type ?? this.type,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      topics: topics ?? this.topics,
      relationshipProgress: relationshipProgress ?? this.relationshipProgress,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
} 