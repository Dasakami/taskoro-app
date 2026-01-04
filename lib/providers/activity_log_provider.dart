import 'package:flutter/material.dart';
import '../models/activity_log_model.dart';
import '../services/api_service.dart';

class ActivityLogProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<ActivityLog> _logs = [];
  bool _isLoading = false;
  String? _error;
  int? _selectedType;
  
  List<ActivityLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedType => _selectedType;
  
  Future<void> fetchActivityLogs() async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/history/activity-log/');
      
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
