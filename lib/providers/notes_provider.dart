import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taskoro/providers/user_provider.dart';

import '../models/note_model.dart';

class NotesProvider with ChangeNotifier {
  final UserProvider userProvider;
  List<Note> _notes = [];

  NotesProvider(this.userProvider);


  List<Note> get activeNotes => _notes.where((n) => !n.isDeleted).toList();
  List<Note> get deletedNotes => _notes.where((n) => n.isDeleted).toList();

  Future<void> fetchNotes() async {
    final token = userProvider.accessToken;
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.232.53:8000/api/notes/notes/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _notes = List<Note>.from(data.map((e) => Note.fromJson(e)));
      notifyListeners();
    }
  }

  Future<void> createNote(String title, String? content) async {
    final token = userProvider.accessToken;
    final response = await http.post(
      Uri.parse('http://192.168.232.53:8000/api/notes/notes/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'content': content,
      }),
    );
    if (response.statusCode == 201) {
      await fetchNotes();
    }
  }

  Future<void> updateNote(int id, String title, String? content) async {
    final token = userProvider.accessToken;
    await http.put(
      Uri.parse('http://192.168.232.53:8000/api/notes/notes/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'content': content,
      }),
    );
    await fetchNotes();
  }

  Future<void> deleteNote(int id) async {
    final token = userProvider.accessToken;
    await http.patch(
      Uri.parse('http://192.168.232.53:8000/api/notes/notes/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'is_deleted': true}),
    );
    await fetchNotes();
  }

  Future<void> restoreNote(int id) async {
    final token = userProvider.accessToken;
    await http.patch(
      Uri.parse('http://192.168.232.53:8000/api/notes/notes/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'is_deleted': false}),
    );
    await fetchNotes();
  }

}
