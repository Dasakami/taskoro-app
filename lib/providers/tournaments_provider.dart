import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/participant.dart';
import '../models/tournaments_model.dart';
import 'user_provider.dart';

class TournamentsProvider with ChangeNotifier {
  final UserProvider userProvider;
  final String baseUrl;

  TournamentsProvider({
    required this.userProvider,
    this.baseUrl = 'http://192.168.232.53:8000',
  });

  final List<Tournament> _tournaments = [];
  List<Tournament> get tournaments => List.unmodifiable(_tournaments);

  // Вспомогательный метод, чтобы не дублировать заголовки
  Map<String, String> _authHeaders() {
    final token = userProvider.accessToken;
    if (token!.isEmpty) {
      throw Exception('Токен не найден, выполните вход');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> fetchTournaments() async {
    final url = Uri.parse('$baseUrl/api/tournaments/');
    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      _tournaments
        ..clear()
        ..addAll(data.map((j) => Tournament.fromJson(j)));
      notifyListeners();
    } else {
      throw Exception('Ошибка загрузки турниров [${resp.statusCode}]');
    }
  }

  List<Tournament> get activeTournaments =>
      _tournaments.where((t) => t.isActive).toList();

  /// Предстоящие (неактивные + дата старта > now)
  List<Tournament> get upcomingTournaments =>
      _tournaments.where((t) =>
      !t.isActive && t.startDate.isAfter(DateTime.now())
      ).toList();

  /// Прошедшие (неактивные + дата старта < now)
  List<Tournament> get pastTournaments =>
      _tournaments.where((t) =>
      !t.isActive && t.startDate.isBefore(DateTime.now())
      ).toList();

  Future<void> joinTournament(int id) async {
    final url = Uri.parse('$baseUrl/api/tournaments/$id/join/');
    final resp = await http.post(url, headers: _authHeaders());

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      // Можно обновить локальный стейт, если нужно
      return;
    }

    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw Exception('Неавторизован: проверьте токен или права доступа');
    }

    // Пытаемся распарсить ошибку из тела
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final error = body['error'] ??
        body['detail'] ??
        'Ошибка участия в турнире [${resp.statusCode}]';
    throw Exception(error);
  }

  Future<List<Participant>> fetchLeaderboard(int tournamentId) async {
    final url = Uri.parse('$baseUrl/api/tournaments/$tournamentId/leaderboard/');
    final resp = await http.get(url, headers: _authHeaders());

    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((j) => Participant.fromJson(j)).toList();
    }

    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw Exception('Неавторизован: проверьте токен или доступ к этому турниру');
    }

    throw Exception('Ошибка загрузки лидерборда [${resp.statusCode}]');
  }
}
