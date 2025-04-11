import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';
import 'dart:convert';

class DiaryEntry {
  final String id;
  final DateTime date;
  final String content;
  final List<String> tags;
  final List<String> imagePaths;
  final String? location;
  final Map<String, dynamic>? attachments;

  DiaryEntry({
    String? id,
    required this.date,
    required this.content,
    this.tags = const [],
    this.imagePaths = const [],
    this.location,
    this.attachments,
  }) : id = id ?? const Uuid().v4();

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      content: map['content'],
      tags: _parseStringList(map['tags']),
      imagePaths: _parseStringList(map['imagePaths']),
      location: map['location'],
      attachments: map['attachments'] != null 
          ? jsonDecode(map['attachments']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'tags': jsonEncode(tags),
      'imagePaths': jsonEncode(imagePaths),
      'location': location,
      'attachments': attachments != null ? jsonEncode(attachments) : null,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(value);
      return decoded.map((item) => item.toString()).toList();
    } catch (e) {
      developer.log('Error al parsear lista: $e');
      return [];
    }
  }

  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    String? content,
    List<String>? tags,
    List<String>? imagePaths,
    String? location,
    Map<String, dynamic>? attachments,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      imagePaths: imagePaths ?? this.imagePaths,
      location: location ?? this.location,
      attachments: attachments ?? this.attachments,
    );
  }
} 