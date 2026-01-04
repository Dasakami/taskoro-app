import 'package:flutter/material.dart';
import '../models/duel_model.dart';
import '../services/api_service.dart';

/// Провайдер для управления дуэлями
class DuelProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  // Данные
  List<DuelModel> _duels = [];
  
  // Состояние
  bool _isLoading = false;
  String? _error;
  
  // ===================== GETTERS =====================
  
  List<DuelModel> get duels => _duels;
  
  List<DuelModel> get pendingDuels =>
      _duels.where((d) => d.status == 'pending').toList();
  List<DuelModel> get activeDuels =>
      _duels.where((d) => d.status == 'active').toList();
  List<DuelModel> get completedDuels =>
      _duels.where((d) => d.status == 'completed' || d.status == 'finished').toList();
  List<DuelModel> get declinedDuels =>
      _duels.where((d) => d.status == 'declined').toList();
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ===================== ЗАГРУЗКА ДАННЫХ =====================
  
  Future<void> fetchDuels({String? status}) async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      String path = '/duels/';
      if (status != null) {
        path += '?status=$status';
      }
      
      final data = await _api.get(path);
      
      if (data is List) {
        _duels = data
            .map((e) => DuelModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final list = data['duels'] as List? ?? [];
        _duels = list
            .map((e) => DuelModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _setError('Ошибка загрузки дуэлей: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ===================== УПРАВЛЕНИЕ ДУЭЛЯМИ =====================
  
  Future<DuelModel?> createDuel({
    required int opponentId,
    required List<int> taskIds,
    required int coinsStake,
  }) async {
    if (!_api.isAuthenticated) return null;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.post('/duels/', body: {
        'opponent_id': opponentId,
        'task_ids': taskIds,
        'coins_stake': coinsStake,
      });
      
      if (data is Map<String, dynamic>) {
        final duel = DuelModel.fromJson(data);
        _duels.add(duel);
        notifyListeners();
        return duel;
      } else {
        throw ApiException('Ошибка создания дуэли');
      }
    } catch (e) {
      _setError('Ошибка создания дуэли: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> acceptDuel(int duelId) async {
    if (!_api.isAuthenticated) return false;
    
    try {
      await _api.post('/duels/$duelId/accept/');
      await fetchDuels();
      return true;
    } catch (e) {
      _setError('Ошибка принятия дуэли: $e');
      return false;
    }
  }
  
  Future<bool> declineDuel(int duelId) async {
    if (!_api.isAuthenticated) return false;
    
    try {
      await _api.post('/duels/$duelId/decline/');
      await fetchDuels();
      return true;
    } catch (e) {
      _setError('Ошибка отклонения дуэли: $e');
      return false;
    }
  }
  
  Future<bool> completeDuel(int duelId, {bool victory = true}) async {
    if (!_api.isAuthenticated) return false;
    
    try {
      await _api.post('/duels/$duelId/complete/', body: {'victory': victory});
      await fetchDuels();
      return true;
    } catch (e) {
      _setError('Ошибка завершения дуэли: $e');
      return false;
    }
  }
  
  // ===================== УТИЛИТЫ =====================
  
  void clearData() {
    _duels.clear();
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
