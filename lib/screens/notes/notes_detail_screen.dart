import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/notes_provider.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'note_form_screen.dart';

class NotesDetailScreen extends StatelessWidget {
  final int noteId;

  const NotesDetailScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    final note = context.read<NotesProvider>().getNoteById(noteId);

    if (note == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Заметка'),
          backgroundColor: AppColors.backgroundSecondary,
        ),
        body: const Center(
          child: Text(
            'Заметка не найдена',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Заметка'),
        backgroundColor: AppColors.backgroundSecondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteFormScreen(
                    noteId: note.id,
                    initialTitle: note.title,
                    initialContent: note.content,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              note.content ?? '',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}