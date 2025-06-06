import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/activity_log_model.dart';

class ActivityLogProvider extends ChangeNotifier {
  List<ActivityLog> logs = [];
  String selectedType = '';

  Future<void> fetchLogs(String token, {String type = ''}) async {
    final url = Uri.parse('http://192.168.232.53:8000/api/history/activity-log/?type=$type');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

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
