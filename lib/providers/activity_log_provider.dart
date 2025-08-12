import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taskoro/providers/user_provider.dart';

import '../models/activity_log_model.dart';

class ActivityLogProvider extends ChangeNotifier {
  final UserProvider userProvider;
  ActivityLogProvider({required this.userProvider});

  List<ActivityLog> logs = [];
  String selectedType = '';

  Future<void> fetchLogs(String token, {String type = ''}) async {
    final url = Uri.parse('https://taskoro.onrender.com/api/history/activity-log/?type=$type');
    final response = await userProvider.authGet(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      logs = data.map((e) => ActivityLog.fromJson(e)).toList();
      selectedType = type;
      notifyListeners();
    } else {
      throw Exception('Failed to fetch activity logs');
    }

  }
}
