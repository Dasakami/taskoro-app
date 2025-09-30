import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:taskoro/providers/user_provider.dart';

import '../models/note_model.dart';

class NotesProvider with ChangeNotifier {
  final UserProvider userProvider;
  List<Note> _notes = [];

  NotesProvider(this.userProvider);

  List<Note> get activeNotes => _notes.where((n) => !n.isDeleted).toList();
  List<Note> get deletedNotes => _notes.where((n) => n.isDeleted).toList();

  Future<void> fetchNotes() async {
    final response = await userProvider.authGet(
      Uri.parse('https://daskoro.site/api/notes/notes/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _notes = List<Note>.from(data.map((e) => Note.fromJson(e)));
      notifyListeners();
    }
  }


  Future<void> createNote(String title, String? content) async {
    final response = await userProvider.authPost(
      Uri.parse('https://daskoro.site/api/notes/notes/'),
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
    await userProvider.authPut(
      Uri.parse('https://daskoro.site/api/notes/notes/$id/'),
      body: json.encode({
        'title': title,
        'content': content,
      }),
    );
    await fetchNotes();
  }

  Future<void> deleteNote(int id) async {
    await userProvider.authPatch(
      Uri.parse('https://daskoro.site/api/notes/notes/$id/'),
      body: json.encode({'is_deleted': true}),
    );
    await fetchNotes();
  }
  Note? getNoteById(int id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }


  Future<void> restoreNote(int id) async {
    await userProvider.authPatch(
      Uri.parse('https://daskoro.site/api/notes/notes/$id/'),
      body: json.encode({'is_deleted': false}),
    );
    await fetchNotes();
  }
}
