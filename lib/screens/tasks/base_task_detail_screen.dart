import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/base_task.dart';
import '../../providers/base_task_provider.dart';
import '../../widgets/magic_card.dart';
import '../../widgets/state_wrapper.dart';
import '../../theme/app_theme.dart';

class BaseTaskDetailScreen extends StatelessWidget {
  static const routeName = '/base-task-detail';

  const BaseTaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)!.settings.arguments as BaseTaskModel;
    final prov = context.read<BaseTaskProvider>();

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
              Text(task.description, style: TextStyle(fontSize: 16)),
              const Divider(height: 32),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.accentPrimary),
                  const SizedBox(width: 8),
                  Text('+${task.xpReward} XP',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentPrimary)),
                ],
              ),
              const Spacer(),
              Center(
                child: ElevatedButton.icon(
                  onPressed: task.completed
                      ? null
                      : () async {
                    final ok = await prov.complete(task);
                    if (ok) {
                      AppSnackBar.showSuccess(context, 'Получено ${task.xpReward} XP');
                    } else {
                      AppSnackBar.showError(context, 'Задача сегодня выполнена');
                    }
                    if (ok) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: Text(task.completed ? 'Выполнено' : 'Выполнить'),
                  style: ElevatedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: task.completed
                        ? Colors.grey
                        : AppColors.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
