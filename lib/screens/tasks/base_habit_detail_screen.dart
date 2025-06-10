import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/base_task.dart';
import '../../providers/base_habit_provider.dart';
import '../../widgets/magic_card.dart';
import '../../theme/app_theme.dart';

class BaseHabitDetailScreen extends StatelessWidget {
  static const routeName = '/base-habit-detail';

  const BaseHabitDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)!.settings.arguments as BaseTaskModel;
    final prov = context.read<BaseHabitProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MagicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(task.description),
              const Divider(height: 32),
              Text('+${task.xpReward} XP',
                  style: TextStyle(
                      color: AppColors.accentSecondary,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: task.completed
                      ? null
                      : () async {
                    final ok = await prov.complete(task);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(ok
                                ? 'Получено ${task.xpReward} XP'
                                : 'Ошибка')));
                    if (ok) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentSecondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12)),
                  child: Text(task.completed ? 'Готово' : 'Выполнить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
