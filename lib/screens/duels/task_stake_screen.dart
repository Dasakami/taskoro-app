import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/duel_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/state_wrapper.dart';

class TaskStakeScreen extends StatefulWidget {
  static const routeName = '/duel-create';
  const TaskStakeScreen({Key? key}) : super(key: key);

  @override
  State<TaskStakeScreen> createState() => _TaskStakeScreenState();
}

class _TaskStakeScreenState extends State<TaskStakeScreen> {
  int? _selectedTaskId;
  final TextEditingController _stakeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _stakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(int opponentId) async {
    if (_selectedTaskId == null) {
      AppSnackBar.showError(context, 'Пожалуйста, выберите задачу');
      return;
    }
    final stakeText = _stakeCtrl.text.trim();
    final stake = int.tryParse(stakeText);
    if (stake == null || stake <= 0) {
      AppSnackBar.showError(context, 'Введите корректную ставку');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<DuelProvider>().createDuel(
        opponentId: opponentId,
        taskIds: [_selectedTaskId!],
        coinsStake: stake,
      );

      AppSnackBar.showSuccess(context, message: 'Дуэль успешно создана');
      Navigator.of(context).pop();
    } catch (e) {
      AppSnackBar.showError(context, 'Ошибка при создании дуэли: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Приводим аргумент к ненулевому int
    final opponentId = ModalRoute.of(context)!.settings.arguments as int;

    final tasks = context.watch<TasksProvider>().tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Новая дуэль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Выберите задачу',
                style: AppTheme.darkTheme.textTheme.bodyLarge),
            const SizedBox(height: 8),

            // Если задач нет — сообщение
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                child: Text('Нет доступных задач',
                    style:
                    AppTheme.darkTheme.textTheme.bodyMedium),
              )
                  : ListView(
                children: tasks.map((task) {
                  return RadioListTile<int>(
                    title: Text(task.title,
                        style: AppTheme
                            .darkTheme.textTheme.bodyMedium),
                    value: task.id!,
                    groupValue: _selectedTaskId,
                    activeColor:
                    AppTheme.darkTheme.colorScheme.primary,
                    onChanged: (value) => setState(
                            () => _selectedTaskId = value),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _stakeCtrl,
              decoration: const InputDecoration(
                labelText: 'Ставка монет',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: () => _submit(opponentId),
              child: const Text('Отправить дуэль'),
            ),
          ],
        ),
      ),
    );
  }
}
