import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/base_habit_provider.dart';
import '../../models/base_task.dart';
import '../../widgets/magic_card.dart';
import '../../theme/app_theme.dart';

class BaseHabitScreen extends StatelessWidget {
  static const routeName = '/base-habits';
  const BaseHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BaseHabitProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!prov.loading && prov.habits.isEmpty && prov.error == null) {
        prov.fetch();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Базовые привычки')),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : prov.error != null
          ? Center(child: Text(prov.error!))
          : RefreshIndicator(
        onRefresh: prov.fetch,
        child: prov.habits.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            Center(child: Text('Нет доступных привычек')),
          ],
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: prov.habits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final task = prov.habits[i];
            return MagicCard(
              child: ListTile(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/base-habit-detail',
                  arguments: task,
                ),
                leading: const Icon(Icons.repeat,
                    color: AppColors.accentSecondary),
                title: Text(task.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                subtitle: Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: ElevatedButton(
                  onPressed: task.completed
                      ? null
                      : () async {
                    final ok =
                    await prov.complete(task);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? 'Получено ${task.xpReward} XP'
                            : 'Ошибка'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.accentSecondary),
                  child:
                  Text(task.completed ? 'Готово' : 'Выполнить'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
