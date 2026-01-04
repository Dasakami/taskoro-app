import 'package:flutter/material.dart';
import '../models/tournaments_model.dart';
import '../services/api_service.dart';

class TournamentsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<Tournament> _tournaments = [];
  bool _isLoading = false;
  String? _error;
  
  List<Tournament> get tournaments => _tournaments;
  List<Tournament> get activeTournaments => _tournaments.where((t) => !t.isCompleted).toList();
  List<Tournament> get completedTournaments => _tournaments.where((t) => t.isCompleted).toList();
  List<Tournament> get upcomingTournaments => _tournaments.where((t) => DateTime.now().isBefore(t.startDate)).toList();
  List<Tournament> get pastTournaments => _tournaments.where((t) => DateTime.now().isAfter(t.endDate)).toList();
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchTournaments() async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/tournaments/');
      
      if (data is List) {
        _tournaments = data.map((e) => Tournament.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map) {
        final list = data['tournaments'] as List? ?? [];
        _tournaments = list.map((e) => Tournament.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _setError('Ошибка загрузки турниров: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> joinTournament(int tournamentId) async {
    try {
      await _api.post('/tournaments/$tournamentId/join/');
      await fetchTournaments();
      return true;
    } catch (e) {
      _setError('Ошибка вступления в турнир: $e');
      return false;
    }
  }
  
  Future<dynamic> fetchLeaderboard([int? tournamentId]) async {
    try {
      final path = tournamentId != null 
          ? '/tournaments/$tournamentId/leaderboard/' 
          : '/leaderboard/';
      return await _api.get(path);
    } catch (e) {
      _setError('Ошибка загрузки рейтинга: $e');
      return null;
    }
  }
  
  void clearData() {
    _tournaments.clear();
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
