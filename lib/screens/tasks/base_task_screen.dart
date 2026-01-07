import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/base_task.dart';
import '../../providers/base_task_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';
import '../../widgets/state_wrapper.dart';
import 'base_task_detail_screen.dart';

class BaseTaskScreen extends StatelessWidget {
  static const routeName = '/base-tasks';
  const BaseTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BaseTaskProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!prov.loading && prov.tasks.isEmpty && prov.error == null) {
        prov.fetchBaseTasks();
      }
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Базовые задачи'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Одноразовые', icon: Icon(Icons.task)),
              Tab(text: 'Привычки', icon: Icon(Icons.repeat)),
              Tab(text: 'Ежедневки', icon: Icon(Icons.calendar_today)),
            ],
          ),
        ),
        body: SafeArea(
          child: prov.loading
              ? const Center(child: CircularProgressIndicator())
              : prov.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(prov.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: prov.fetchBaseTasks,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  children: [
                    _buildTab(context, prov, prov.oneTimers),
                    _buildTab(context, prov, prov.habits),
                    _buildTab(context, prov, prov.dailies),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    BaseTaskProvider prov,
    List<BaseTaskModel> list,
  ) {
    // Сортируем: невыполненные сначала
    final sortedList = List<BaseTaskModel>.from(list);
    sortedList.sort((a, b) {
      if (a.completed == b.completed) return 0;
      return a.completed ? 1 : -1;
    });

    return RefreshIndicator(
      onRefresh: prov.fetchBaseTasks,
      child: sortedList.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Center(child: Text('Нет доступных задач')),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final task = sortedList[i];
                return MagicCard(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        BaseTaskDetailScreen.routeName,
                        arguments: task,
                      );
                    },
                    child: Opacity(
                      opacity: task.completed ? 0.5 : 1.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Иконка с галочкой если выполнено
                            Stack(
                              children: [
                                _iconForType(task.type),
                                if (task.completed)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Заголовок + описание
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: task.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    task.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      decoration: task.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // XP + кнопка
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentPrimary
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: AppColors.accentPrimary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+${task.xpReward}',
                                        style: const TextStyle(
                                          color: AppColors.accentPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: task.completed
                                      ? null
                                      : () async {
                                          final ok = await prov.complete(task);
                                          if (ok && context.mounted) {
                                            AppSnackBar.showSuccess(
                                              context,
                                              'Получено ${task.xpReward} XP',
                                            );
                                          } else if (!ok && context.mounted) {
                                            AppSnackBar.showError(
                                              context,
                                              'Задача уже выполнена сегодня',
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: task.completed
                                        ? Colors.grey
                                        : AppColors.accentPrimary,
                                  ),
                                  child: Text(
                                    task.completed ? '✓ Готово' : 'Выполнить',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _iconForType(BaseTaskType type) {
    switch (type) {
      case BaseTaskType.oneTime:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accentPrimary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.task,
            color: AppColors.accentPrimary,
            size: 20,
          ),
        );
      case BaseTaskType.habit:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accentSecondary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.repeat,
            color: AppColors.accentSecondary,
            size: 20,
          ),
        );
      case BaseTaskType.daily:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accentTertiary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.calendar_today,
            color: AppColors.accentTertiary,
            size: 20,
          ),
        );
    }
  }
}