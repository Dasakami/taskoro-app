// providers/duel_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/duel_model.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';

class DuelProvider extends ChangeNotifier {
  List<DuelModel> _duels = [];
  List<DuelModel> get duels => _duels;

  Future<void> fetchDuels(String accessToken, {String? status}) async {
    final baseUrl = 'http://192.168.232.53:8000/api/duels/duels/';
    final url = status != null ? Uri.parse('$baseUrl?status=$status') : Uri.parse(baseUrl);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _duels = List<DuelModel>.from(data.map((json) => DuelModel.fromJson(json)));
      notifyListeners();
    } else {
      throw Exception('Ошибка загрузки дуэлей: ${response.body}');
    }
  }

  Future<void> acceptDuel(String token, int duelId) async {
    final response = await http.post(
      Uri.parse('http://192.168.232.53:8000/api/duels/$duelId/accept/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка принятия дуэли');
    }
  }

  Future<void> declineDuel(String token, int duelId) async {
    final response = await http.post(
      Uri.parse('http://192.168.232.53:8000/api/duels/$duelId/decline/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка отклонения дуэли');
    }
  }

  Future<void> createDuel({
    required String token,
    required int opponentId,
    required List<int> taskIds,
    required int coinsStake,
  }) async {
    final url = Uri.parse('http://192.168.232.53:8000/api/duels/duels/');

    final body = jsonEncode({
      'opponent_id': opponentId,
      'task_ids': taskIds,
      'coins_stake': coinsStake,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create duel: ${response.body}');
    }

    // Если нужно — можешь здесь обновить локальный список дуэлей и вызвать notifyListeners()
  }
}
