import 'package:flutter/foundation.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/services/database_service.dart';

class ContactProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Contact> _contacts = [];
  final Map<String, List<Interaction>> _interactions = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Listas filtradas por estado de archivo
  List<Contact> get activeContacts => _contacts.where((contact) => !contact.isArchived).toList();
  List<Contact> get archivedContacts => _contacts.where((contact) => contact.isArchived).toList();

  List<Interaction> getInteractionsForContact(String contactId) {
    return _interactions[contactId] ?? [];
  }

  Future<void> loadContacts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _contacts = await _databaseService.getContacts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar los contactos: $e';
      notifyListeners();
    }
  }

  Future<void> loadInteractionsForContact(String contactId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final interactions = await _databaseService.getInteractionsByContactId(contactId);
      _interactions[contactId] = interactions;
      
      // Actualizar el último contacto en el objeto de contacto
      if (interactions.isNotEmpty && interactions.first.date.isAfter(
          _contacts.firstWhere((c) => c.id == contactId).lastInteraction ?? DateTime(1970))) {
        final contact = _contacts.firstWhere((c) => c.id == contactId);
        final updatedContact = contact.copyWith(lastInteraction: interactions.first.date);
        
        await _databaseService.updateContact(updatedContact);
        
        final index = _contacts.indexWhere((c) => c.id == contactId);
        if (index != -1) {
          _contacts[index] = updatedContact;
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar las interacciones: $e';
      notifyListeners();
    }
  }

  Future<void> addContact(Contact contact) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.insertContact(contact);
      await loadContacts();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al añadir el contacto: $e';
      notifyListeners();
    }
  }

  Future<void> updateContact(Contact contact) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.updateContact(contact);
      await loadContacts();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar el contacto: $e';
      notifyListeners();
    }
  }

  Future<void> deleteContact(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.deleteContact(id);
      _interactions.remove(id);
      await loadContacts();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar el contacto: $e';
      notifyListeners();
    }
  }

  Future<void> addInteraction(Interaction interaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.insertInteraction(interaction);
      
      // Actualizar el contact con la última interacción
      final contact = _contacts.firstWhere((c) => c.id == interaction.contactId);
      if (contact.lastInteraction == null || 
          interaction.date.isAfter(contact.lastInteraction!)) {
        final updatedContact = contact.copyWith(lastInteraction: interaction.date);
        await _databaseService.updateContact(updatedContact);
      }
      
      await loadContacts();
      await loadInteractionsForContact(interaction.contactId);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al añadir la interacción: $e';
      notifyListeners();
    }
  }

  Future<void> updateInteraction(Interaction interaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.updateInteraction(interaction);
      await loadInteractionsForContact(interaction.contactId);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar la interacción: $e';
      notifyListeners();
    }
  }

  Future<void> deleteInteraction(String id, String contactId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.deleteInteraction(id);
      await loadInteractionsForContact(contactId);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar la interacción: $e';
      notifyListeners();
    }
  }

  Future<void> archiveContact(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final contact = _contacts.firstWhere((c) => c.id == id);
      final updatedContact = contact.copyWith(isArchived: true);
      
      await _databaseService.updateContact(updatedContact);
      await loadContacts();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al archivar el contacto: $e';
      notifyListeners();
    }
  }
  
  Future<void> unarchiveContact(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final contact = _contacts.firstWhere((c) => c.id == id);
      final updatedContact = contact.copyWith(isArchived: false);
      
      await _databaseService.updateContact(updatedContact);
      await loadContacts();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al desarchivar el contacto: $e';
      notifyListeners();
    }
  }

  List<Contact> searchContacts({
    String? keyword,
    int? minInterestLevel,
    int? maxInterestLevel,
    String? meetingPlace,
    bool showArchived = false,
  }) {
    return _contacts.where((contact) {
      // Filtrar por estado de archivo
      if (!showArchived && contact.isArchived) {
        return false;
      }
      
      bool matchesKeyword = keyword == null ||
          keyword.isEmpty ||
          contact.name.toLowerCase().contains(keyword.toLowerCase()) ||
          (contact.notes != null && 
           contact.notes!.toLowerCase().contains(keyword.toLowerCase()));

      bool matchesInterestLevel = (minInterestLevel == null || 
                                   contact.interestLevel >= minInterestLevel) &&
                                  (maxInterestLevel == null || 
                                   contact.interestLevel <= maxInterestLevel);

      bool matchesMeetingPlace = meetingPlace == null ||
          meetingPlace.isEmpty ||
          (contact.meetingPlaces.any((place) => 
            place.toLowerCase().contains(meetingPlace.toLowerCase())));

      return matchesKeyword && matchesInterestLevel && matchesMeetingPlace;
    }).toList();
  }

  List<Contact> sortContactsByLastInteraction() {
    final sortedContacts = List<Contact>.from(_contacts);
    sortedContacts.sort((a, b) {
      if (a.lastInteraction == null && b.lastInteraction == null) {
        return 0;
      } else if (a.lastInteraction == null) {
        return 1;
      } else if (b.lastInteraction == null) {
        return -1;
      }
      return b.lastInteraction!.compareTo(a.lastInteraction!);
    });
    return sortedContacts;
  }

  List<String> getCommonMeetingPlaces() {
    final Set<String> places = {};
    for (var contact in _contacts) {
      for (var place in contact.meetingPlaces) {
        if (place.isNotEmpty) {
          places.add(place);
        }
      }
    }
    return places.toList()..sort();
  }
} 