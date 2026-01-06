import 'package:flutter/material.dart';
import '../models/activity_log_model.dart';
import '../services/api_service.dart';

class ActivityLogProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<ActivityLog> _logs = [];
  bool _isLoading = false;
  String? _error;
  String _selectedType = '';
  
  List<ActivityLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedType => _selectedType;
  
  /// Установить фильтр по типу активности
  void setFilter(String type) {
    _selectedType = type;
    notifyListeners();
  }
  
  Future<void> fetchActivityLogs() async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      // Если выбран фильтр, добавляем его в запрос
      String endpoint = '/history/activity-log/';
      if (_selectedType.isNotEmpty) {
        endpoint += '?type=$_selectedType';
      }
      
      final data = await _api.get(endpoint);
      
      if (data is List) {
        _logs = data.map((e) => ActivityLog.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map) {
        final list = data['logs'] as List? ?? [];
        _logs = list.map((e) => ActivityLog.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _setError('Ошибка загрузки логов: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Alias для fetchActivityLogs
  Future<void> fetchLogs() => fetchActivityLogs();
  
  void clearData() {
    _logs.clear();
    _error = null;
    _isLoading = false;
    _selectedType = '';
    notifyListeners();
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}