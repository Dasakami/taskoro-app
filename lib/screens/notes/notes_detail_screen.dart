import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/notes_provider.dart';
import 'package:taskoro/theme/app_theme.dart';
class NotesDetailScreen extends StatelessWidget {
  final int noteId;

  const NotesDetailScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    final note = context.read<NotesProvider>().getNoteById(noteId);

    if (note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Заметка')),
        body: const Center(child: Text('Заметка не найдена')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Заметка')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  note.content ?? '',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
