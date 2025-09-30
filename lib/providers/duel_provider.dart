

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/duel_model.dart';

class DuelProvider extends ChangeNotifier {
  final String baseUrl = 'https://daskoro.site/api/duels';
  List<DuelModel> _duels = [];

  List<DuelModel> get duels => List.unmodifiable(_duels);

  List<DuelModel> get pendingDuels =>
      _duels.where((d) => d.status == 'pending').toList();
  List<DuelModel> get activeDuels =>
      _duels.where((d) => d.status == 'active').toList();
  List<DuelModel> get declinedDuels =>
      _duels.where((d) => d.status == 'declined').toList();
  List<DuelModel> get completedDuels =>
      _duels.where((d) => d.status == 'completed' || d.status == 'finished').toList();

  Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<void> fetchDuels(String token, {String? status}) async {
    final uri = status != null
        ? Uri.parse('$baseUrl/duels/?status=$status')
        : Uri.parse('$baseUrl/duels/');
    final res = await http.get(uri, headers: _authHeaders(token));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      _duels = data.map((j) => DuelModel.fromJson(j)).toList();
      notifyListeners();
    } else {
      throw Exception('Ошибка загрузки дуэлей: ${res.body}');
    }
  }

  Future<void> acceptDuel(String token, int id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/duels/$id/accept/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) {
      await fetchDuels(token);
    } else {
      throw Exception('Ошибка accept');
    }
  }

  Future<void> declineDuel(String token, int id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/duels/$id/decline/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) {
      await fetchDuels(token);
    } else {
      throw Exception('Ошибка decline');
    }
  }

  Future<void> createDuel({
    required String token,
    required int opponentId,
    required List<int> taskIds,
    required int coinsStake,
  }) async {
    final uri = Uri.parse('https://daskoro.site/api/duels/duels/');
    final body = jsonEncode({
      'opponent_id': opponentId,
      'task': taskIds.first,
      'coins_stake': coinsStake,
    });
    final res = await http.post(uri, headers: _authHeaders(token), body: body);

    if (res.statusCode == 201) {
      final duel = DuelModel.fromJson(jsonDecode(res.body));
      _duels.insert(0, duel);
      notifyListeners();
    } else {
      throw Exception('Не удалось создать дуэль: ${res.statusCode} ${res.body}');
    }
  }

}
