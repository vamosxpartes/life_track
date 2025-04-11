import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';
import 'dart:convert';

class Contact {
  final String id;
  final String name;
  final String? photoPath;
  final String? phoneNumber;
  final String? email;
  final DateTime? birthdate;
  final String? occupation;
  final List<String> meetingPlaces;
  final int interestLevel; // 1-9
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? lastInteraction;
  final bool isArchived;
  
  // Nuevos campos para características físicas
  final String? height;
  final String? bodyType; // delgada, atlética, promedio, etc.
  final String? eyeColor;
  final String? hairColor;
  final String? buttocksSize;
  final String? breastsSize;
  final String? waistSize;
  
  // Nuevos campos para personalidad
  final List<String> personalityTraits;
  
  // Nuevo campo para estado sentimental
  final String? relationshipStatus; // soltera, con novio, casada, etc.

  Contact({
    String? id,
    required this.name,
    this.photoPath,
    this.phoneNumber,
    this.email,
    this.birthdate,
    this.occupation,
    this.meetingPlaces = const [],
    this.interestLevel = 5,
    this.notes,
    this.tags = const [],
    DateTime? createdAt,
    this.lastInteraction,
    this.height,
    this.bodyType,
    this.eyeColor,
    this.hairColor,
    this.buttocksSize,
    this.breastsSize,
    this.waistSize,
    this.personalityTraits = const [],
    this.relationshipStatus,
    this.isArchived = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Contact.fromMap(Map<String, dynamic> map) {
    List<String> parseTags(dynamic tagsData) {
      if (tagsData == null) return [];
      
      try {
        // Si ya es una lista de strings, devolverla directamente
        if (tagsData is List) {
          return tagsData.map((e) => e.toString()).toList();
        }
        
        // Intentar decodificar como JSON
        final List<dynamic> decoded = jsonDecode(tagsData);
        return decoded.map((item) => item.toString()).toList();
      } catch (e) {
        developer.log('Error al parsear tags: $e');
        return [];
      }
    }

    return Contact(
      id: map['id'],
      name: map['name'],
      photoPath: map['photoPath'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      birthdate: map['birthdate'] != null ? DateTime.parse(map['birthdate']) : null,
      occupation: map['occupation'],
      meetingPlaces: parseTags(map['meetingPlaces']),
      interestLevel: map['interestLevel'] ?? 5,
      notes: map['notes'],
      tags: parseTags(map['tags']),
      createdAt: DateTime.parse(map['createdAt']),
      lastInteraction: map['lastInteraction'] != null
          ? DateTime.parse(map['lastInteraction'])
          : null,
      height: map['height'],
      bodyType: map['bodyType'],
      eyeColor: map['eyeColor'],
      hairColor: map['hairColor'],
      buttocksSize: map['buttocksSize'],
      breastsSize: map['breastsSize'],
      waistSize: map['waistSize'],
      personalityTraits: parseTags(map['personalityTraits']),
      relationshipStatus: map['relationshipStatus'],
      isArchived: map['isArchived'] == 1 || map['isArchived'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoPath': photoPath,
      'phoneNumber': phoneNumber,
      'email': email,
      'birthdate': birthdate?.toIso8601String(),
      'occupation': occupation,
      'meetingPlaces': jsonEncode(meetingPlaces),
      'interestLevel': interestLevel,
      'notes': notes,
      'tags': jsonEncode(tags),
      'createdAt': createdAt.toIso8601String(),
      'lastInteraction': lastInteraction?.toIso8601String(),
      'height': height,
      'bodyType': bodyType,
      'eyeColor': eyeColor,
      'hairColor': hairColor,
      'buttocksSize': buttocksSize,
      'breastsSize': breastsSize,
      'waistSize': waistSize,
      'personalityTraits': jsonEncode(personalityTraits),
      'relationshipStatus': relationshipStatus,
      'isArchived': isArchived ? 1 : 0,
    };
  }

  Contact copyWith({
    String? id,
    String? name,
    String? photoPath,
    String? phoneNumber,
    String? email,
    DateTime? birthdate,
    String? occupation,
    List<String>? meetingPlaces,
    int? interestLevel,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastInteraction,
    String? height,
    String? bodyType,
    String? eyeColor,
    String? hairColor,
    String? buttocksSize,
    String? breastsSize,
    String? waistSize,
    List<String>? personalityTraits,
    String? relationshipStatus,
    bool? isArchived,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      birthdate: birthdate ?? this.birthdate,
      occupation: occupation ?? this.occupation,
      meetingPlaces: meetingPlaces ?? this.meetingPlaces,
      interestLevel: interestLevel ?? this.interestLevel,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      height: height ?? this.height,
      bodyType: bodyType ?? this.bodyType,
      eyeColor: eyeColor ?? this.eyeColor,
      hairColor: hairColor ?? this.hairColor,
      buttocksSize: buttocksSize ?? this.buttocksSize,
      breastsSize: breastsSize ?? this.breastsSize,
      waistSize: waistSize ?? this.waistSize,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      isArchived: isArchived ?? this.isArchived,
    );
  }
} 