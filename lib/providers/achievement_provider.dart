import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taskoro/providers/user_provider.dart';

import '../models/achievement_model.dart';

class AchievementProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];
  final UserProvider userProvider;
  AchievementProvider({required this.userProvider});
  bool _isLoading = false;
  String? _errorMessage;

  List<Achievement> get achievements => _achievements;
  int get totalCount => _achievements.length;
  int get acquiredCount => _achievements.where((a) => a.isAcquired).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final String apiUrl = 'https://taskoro.onrender.com/api/history/achievements/';

  Future<void> fetchAchievements(String accessToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {

      final response = await userProvider.authGet(Uri.parse(apiUrl),);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> achievementsJson = data['achievements'];
        _achievements = achievementsJson
            .map((json) => Achievement.fromJson(json))
            .toList();

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Ошибка загрузки достижений: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Ошибка сети: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
