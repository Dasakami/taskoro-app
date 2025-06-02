import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taskoro/models/user_model.dart';
import 'package:http_parser/http_parser.dart';  // для MediaType
import 'package:mime/mime.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _refreshToken;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
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
    final url = Uri.parse('http://192.168.1.64:8000/api/token/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _accessToken = data['access'];
      _refreshToken = data['refresh'];

      await fetchUserProfile(); // ← вот здесь загрузим профиль

      _isAuthenticated = true;
      notifyListeners();
    } else {
      throw Exception(data['detail'] ?? 'Ошибка авторизации');
    }

    if (response.statusCode == 401) {
      await refreshAccessToken();
      return fetchUserProfile(); // повторная попытка
    }

  }

  Future<void> fetchUserProfile() async {
    if (_accessToken == null) return;

    final url = Uri.parse('http://192.168.1.64:8000/api/users/me/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _user = UserModel.fromJson(data);
      notifyListeners();
    } else {
      print("Ошибка при получении профиля: ${response.statusCode}");
    }
  }


  /// Регистрация
  Future<void> register(String username, String password) async {
    final url = Uri.parse('http://192.168.1.64:8000/api/auth/users/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        're_password': password,
      }),
    );

    if (response.statusCode == 201) {
      // После регистрации — логин
      await login(username, password);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data.toString());
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

    final url = Uri.parse('http://192.168.1.64:8000/api/users/me/edit/');

    http.Response response;

    if (avatarFilePath != null) {
      // Загрузка с файлом через multipart/form-data
      var request = http.MultipartRequest('PATCH', url);
      request.headers['Authorization'] = 'Bearer $_accessToken';

      request.fields['username'] = username;
      request.fields['bio'] = bio;

      // Определяем mime-тип файла
      final mimeType = lookupMimeType(avatarFilePath) ?? 'application/octet-stream';
      final mimeParts = mimeType.split('/');

      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        avatarFilePath,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      ));

      final streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    } else {
      // Обновление без файла — отправляем JSON (если avatarUrl передан, включаем в JSON)
      final body = {
        'username': username,
        'bio': bio,
      };

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

  Future<void> refreshAccessToken() async {
    if (_refreshToken == null) return;

    final url = Uri.parse('http://192.168.1.64:8000/api/token/refresh/');
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
      logout(); // refresh невалиден — выходим из аккаунта
      throw Exception('Ошибка обновления токена');
    }
  }

}




