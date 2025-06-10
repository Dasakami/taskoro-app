import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart'; // для MediaType
import 'package:mime/mime.dart';

import '../models/character_class_model.dart';
import '../models/user_model.dart';
import '../screens/main/daily_mission.dart';
import '../screens/main/daily_motivation.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  DailyMission? _dailyMission;
  DailyMotivation? _dailyMotivation;
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _refreshToken;
  final String _baseUrl = 'http://192.168.232.53:8000/api';

  UserModel? get user => _user;

  DailyMission? get dailyMission => _dailyMission;

  DailyMotivation? get dailyMotivation => _dailyMotivation;

  bool get isAuthenticated => _isAuthenticated;
  List<CharacterClassModel> characterClasses = [];
  bool isLoadingClasses = false;
  String? get baseUrl => _baseUrl;

  String? get accessToken => _accessToken;

  /// Демо-пользователь (без подключения к серверу)
  void initDemoUser() {
    _user = UserModel(
      id: '1',
      username: 'DemoUser',
      level: 5,
      experience: 75,
      experienceNeeded: 150,
      coins: 240,
      gems: 15,
      streak: 3,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Логин с сервера
  Future<void> login(String username, String password) async {
    final url = Uri.parse('http://192.168.232.53:8000/api/token/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _accessToken = data['access'];
      _refreshToken = data['refresh'];

      await Future.wait([fetchUserData(), fetchMainData()]);

      _isAuthenticated = true;
      notifyListeners();
    } else {
      throw Exception(data['detail'] ?? 'Ошибка авторизации');
    }

    if (response.statusCode == 401) {
      await refreshAccessToken();
      return fetchUserData(); // повторная попытка
    }
  }

  /// Получение данных пользователя с сервера, включая профиль, миссию и мотивацию
  Future<void> fetchUserData() async {
    if (_accessToken == null) return;

    final url = Uri.parse('$_baseUrl/users/me/');
    final response = await authGet(Uri.parse('$_baseUrl/users/me/'));


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _user = UserModel.fromJson(data);
      notifyListeners();
    }
  }

  Future<void> fetchMainData() async {
    if (_accessToken == null) return;

    final url = Uri.parse('$_baseUrl/main/');
    final response = await authGet(Uri.parse('$_baseUrl/main/'));


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['daily_mission'] != null) {
        _dailyMission = DailyMission.fromJson(data['daily_mission']);
      }

      if (data['daily_motivation'] != null) {
        _dailyMotivation = DailyMotivation.fromJson(data['daily_motivation']);
      }

      notifyListeners();
    }
  }


  Future<void> fetchCharacterClasses() async {
    isLoadingClasses = true;
    notifyListeners();

    final uri = Uri.parse('$_baseUrl/users/character-classes/');
    final headers = {'Content-Type': 'application/json'};
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      characterClasses = (data['classes'] as List)
          .map((e) => CharacterClassModel.fromJson(e))
          .toList();
      // опционально можно сохранить data['selected_ids']
    } else {
      throw Exception('Не удалось загрузить классы: ${response.statusCode}');
    }

    isLoadingClasses = false;
    notifyListeners();
  }

  /// Регистрация: принимает class_id, сразу отдаёт токены
  Future<void> register(
      String username,
      String email,
      String password,
      int classId,
      ) async {
    final uri = Uri.parse('$_baseUrl/users/register/'
        ''
        ''); // <-- исправлено
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
      're_password': password,
      'class_id': classId,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error.toString());
    }

    // Если 201 — сохраняем токены
    final data = jsonDecode(response.body);
    _accessToken  = data['access'];
    _refreshToken = data['refresh'];

    // Сразу подгружаем профиль, main и классы
    await Future.wait([
      fetchUserData(),        // https://…/api/profile/
      fetchMainData(),        // твой /api/main/
      fetchCharacterClasses() // https://…/api/character-classes/
    ]);

    _isAuthenticated = true;
    notifyListeners();
  }


  Future<void> updateSelectedClasses(List<int> ids) async {
    final uri = Uri.parse('$_baseUrl/users/character-classes/');
    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    final body = jsonEncode({'selected_ids': ids});

    final response = await http.patch(uri, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception('Не удалось обновить выбранный класс');
    }
  }
  /// Выход
  void logout() {
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Прокачка опыта (локально)
  void updateExperience(int amount) {
    if (_user == null) return;

    int newExperience = _user!.experience + amount;
    int newLevel = _user!.level;
    int experienceNeeded = _user!.experienceNeeded;

    while (newExperience >= experienceNeeded) {
      newExperience -= experienceNeeded;
      newLevel++;
      experienceNeeded = (experienceNeeded * 1.5).round();
    }

    _user = _user!.copyWith(
      experience: newExperience,
      level: newLevel,
      experienceNeeded: experienceNeeded,
    );

    notifyListeners();
  }

  /// Валюта (локально)
  void updateCurrency({int coins = 0, int gems = 0}) {
    if (_user == null) return;

    _user = _user!.copyWith(
      coins: _user!.coins + coins,
      gems: _user!.gems + gems,
    );

    notifyListeners();
  }

  Future<void> updateProfile({
    required String username,
    required String bio,
    String? avatarFilePath,
    String? avatarUrl,
  }) async {
    if (_accessToken == null) throw Exception('User not authenticated');

    final url = Uri.parse('http://192.168.232.53:8000/api/users/me/edit/');

    http.Response response;

    if (avatarFilePath != null) {
      // Загрузка с файлом через multipart/form-data
      var request = http.MultipartRequest('PATCH', url);
      request.headers['Authorization'] = 'Bearer $_accessToken';

      request.fields['username'] = username;
      request.fields['bio'] = bio;

      // Определяем mime-тип файла
      final mimeType =
          lookupMimeType(avatarFilePath) ?? 'application/octet-stream';
      final mimeParts = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          avatarFilePath,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        ),
      );

      final streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    } else {
      // Обновление без файла — отправляем JSON (если avatarUrl передан, включаем в JSON)
      final body = {'username': username, 'bio': bio};

      response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _user = UserModel.fromJson(data);
      notifyListeners();
    } else {
      final data = response.body;
      throw Exception('Ошибка обновления профиля: $data');
    }
  }
  Future<http.Response> authGet(Uri url) async {
    var response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 401) {
      await refreshAccessToken();
      response = await http.get(url, headers: _authHeaders());
    }

    return response;
  }


  /// Заголовки авторизации
  Map<String, String> _authHeaders() {
    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
  }

  Future<void> refreshAccessToken() async {
    if (_refreshToken == null) return;

    final url = Uri.parse('$_baseUrl/token/refresh/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access'];
      notifyListeners();
    } else {
      logout();
    }
  }

  Future<void> refreshMainData() async {
    await Future.wait([
      fetchUserData(),
      fetchMainData(),
    ]);}
}
