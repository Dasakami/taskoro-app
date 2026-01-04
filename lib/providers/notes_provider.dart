import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/api_service.dart';

/// Провайдер для управления заметками
class NotesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  // Данные
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;
  
  // ===================== GETTERS =====================
  
  List<Note> get allNotes => _notes;
  List<Note> get activeNotes => _notes.where((n) => !n.isDeleted).toList();
  List<Note> get deletedNotes => _notes.where((n) => n.isDeleted).toList();
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ===================== ЗАГРУЗКА ДАННЫХ =====================
  
  Future<void> fetchNotes() async {
    if (!_api.isAuthenticated) {
      _notes = [];
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/notes/notes/');
      
      if (data is List) {
        _notes = data
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final list = data['notes'] as List? ?? [];
        _notes = list
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _setError('Ошибка загрузки заметок: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ===================== СОЗДАНИЕ И РЕДАКТИРОВАНИЕ =====================
  
  Future<void> createNote(String title, String? content) async {
    if (!_api.isAuthenticated) {
      _setError('Не авторизован');
      return;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      await _api.post('/notes/notes/', body: {
        'title': title,
        'content': content,
      });
      await fetchNotes();
    } catch (e) {
      _setError('Ошибка создания заметки: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateNote(int id, String title, String? content) async {
    if (!_api.isAuthenticated) {
      _setError('Не авторизован');
      return;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      await _api.put('/notes/notes/$id/', body: {
        'title': title,
        'content': content,
      });
      await fetchNotes();
    } catch (e) {
      _setError('Ошибка обновления заметки: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ===================== УДАЛЕНИЕ И ВОССТАНОВЛЕНИЕ =====================
  
  Future<void> deleteNote(int id) async {
    if (!_api.isAuthenticated) {
      _setError('Не авторизован');
      return;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      await _api.patch('/notes/notes/$id/', body: {'is_deleted': true});
      await fetchNotes();
    } catch (e) {
      _setError('Ошибка удаления заметки: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> restoreNote(int id) async {
    if (!_api.isAuthenticated) {
      _setError('Не авторизован');
      return;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      await _api.patch('/notes/notes/$id/', body: {'is_deleted': false});
      await fetchNotes();
    } catch (e) {
      _setError('Ошибка восстановления заметки: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Безвозвратное удаление
  Future<void> deleteNotePermanently(int id) async {
    if (!_api.isAuthenticated) {
      _setError('Не авторизован');
      return;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      await _api.delete('/notes/notes/$id/');
      await fetchNotes();
    } catch (e) {
      _setError('Ошибка удаления заметки: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ===================== УТИЛИТЫ =====================
  
  Note? getNoteById(int id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
  
  void clearData() {
    _notes.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
  
  // ===================== ПРИВАТНЫЕ МЕТОДЫ =====================
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
