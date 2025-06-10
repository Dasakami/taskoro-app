import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:taskoro/providers/user_provider.dart';

import '../models/base_task.dart';

class BaseTaskProvider with ChangeNotifier {
  final UserProvider _userProvider;

  BaseTaskProvider(this._userProvider);

  // теперь URL берётся напрямую
  String? get _baseUrl => _userProvider.baseUrl;

  List<BaseTaskModel> _tasks = [];
  bool _loading = false;
  String? _error;

  List<BaseTaskModel> get tasks => _tasks;
  bool get loading => _loading;
  String? get error => _error;

  /// Загрузка всех базовых заданий
  Future<void> fetchBaseTasks() async {
    final token = _userProvider.accessToken;
    if (token == null) return;

    _loading = true;
    notifyListeners();

    final uri = Uri.parse('$_baseUrl/tasks/base-tasks/');
    final resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      _tasks = data
          .map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } else if (resp.statusCode == 401) {
      await _userProvider.refreshAccessToken();
      return fetchBaseTasks();
    } else {
      _error = 'Ошибка ${resp.statusCode}';
    }

    _loading = false;
    notifyListeners();
  }

  /// Отметить выполнение
  Future<bool> complete(BaseTaskModel task) async {
    final token = _userProvider.accessToken;
    if (token == null) return false;

    final uri =
    Uri.parse('$_baseUrl/tasks/base-tasks/${task.id}/complete/');
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'base_task_id': task.id}),
    );

    if (resp.statusCode == 200) {
      task.completed = true;
      _userProvider.updateExperience(task.xpReward);
      _userProvider.updateCurrency(coins: task.xpReward ~/ 4);
      notifyListeners();
      return true;
    } else if (resp.statusCode == 401) {
      await _userProvider.refreshAccessToken();
      return complete(task);
    } else if (resp.statusCode == 400) {
      _error = 'Задача сегодня выполнено';
      return false;
    }


    return false;
  }

  // Геттеры по типам
  List<BaseTaskModel> get oneTimers =>
      _tasks.where((t) => t.type == BaseTaskType.oneTime).toList();
  List<BaseTaskModel> get habits =>
      _tasks.where((t) => t.type == BaseTaskType.habit).toList();
  List<BaseTaskModel> get dailies =>
      _tasks.where((t) => t.type == BaseTaskType.daily).toList();
}
