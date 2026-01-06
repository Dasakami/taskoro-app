import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/notes_provider.dart';
import 'package:taskoro/theme/app_theme.dart';

class NoteFormScreen extends StatefulWidget {
  final int? noteId;
  final String? initialTitle;
  final String? initialContent;

  const NoteFormScreen({
    super.key,
    this.noteId,
    this.initialTitle,
    this.initialContent,
  });

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isMarkdownMode = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _insertMarkdown(String syntax) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final start = selection.start;
    final end = selection.end;

    String newText;
    int newCursorPos;

    if (start == end) {
      // Ничего не выделено - вставляем синтаксис
      newText = text.substring(0, start) + syntax + text.substring(end);
      newCursorPos = start + syntax.length;
    } else {
      // Что-то выделено - оборачиваем
      final selectedText = text.substring(start, end);
      newText = text.substring(0, start) +
          syntax +
          selectedText +
          syntax +
          text.substring(end);
      newCursorPos = start + syntax.length + selectedText.length + syntax.length;
    }

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noteId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать' : 'Новая заметка'),
        backgroundColor: AppColors.backgroundSecondary,
        actions: [
          IconButton(
            icon: Icon(_isMarkdownMode ? Icons.visibility : Icons.edit),
            onPressed: () {
              setState(() {
                _isMarkdownMode = !_isMarkdownMode;
              });
            },
            tooltip: _isMarkdownMode ? 'Режим редактирования' : 'Режим превью',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Заголовок
            TextField(
              controller: _titleController,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Заголовок',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Markdown панель
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _markdownButton('**', 'Жирный', Icons.format_bold),
                  _markdownButton('*', 'Курсив', Icons.format_italic),
                  _markdownButton('~~', 'Зачёркнутый', Icons.strikethrough_s),
                  _markdownButton('`', 'Код', Icons.code),
                  _markdownButton('# ', 'Заголовок', Icons.title),
                  _markdownButton('- ', 'Список', Icons.format_list_bulleted),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Содержимое
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  labelText: 'Содержание',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.accentPrimary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final title = _titleController.text.trim();
                  final content = _contentController.text.trim();

                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Введите заголовок заметки')),
                    );
                    return;
                  }

                  if (isEditing) {
                    await context.read<NotesProvider>().updateNote(
                          widget.noteId!,
                          title,
                          content,
                        );
                  } else {
                    await context.read<NotesProvider>().createNote(
                          title,
                          content,
                        );
                  }

                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Сохранить' : 'Создать',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _markdownButton(String syntax, String tooltip, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: ElevatedButton(
          onPressed: () => _insertMarkdown(syntax),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.backgroundSecondary,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(0, 36),
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}