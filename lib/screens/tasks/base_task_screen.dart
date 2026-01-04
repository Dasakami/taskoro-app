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
              ? Center(child: Text(prov.error!))
              : Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTab(context, prov, prov.oneTimers),
                    _buildTab(context, prov, prov.habits),
                    _buildTab(context, prov, prov.dailies),
                  ],
                ),
              ),
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
    return RefreshIndicator(
      onRefresh: prov.fetchBaseTasks,
      child: list.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          Center(child: Text('Нет доступных задач')),
        ],
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final task = list[i];
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconForType(task.type),
                    const SizedBox(width: 12),
                    // Заголовок + описание
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                        Text(
                          '+${task.xpReward} XP',
                          style: TextStyle(
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: task.completed
                              ? null
                              : () async {
                            final ok = await prov.complete(task);
                            if (ok) {
                              AppSnackBar.showSuccess(context, message: 'Получено ${task.xpReward} XP');
                            } else {
                              AppSnackBar.showError(context, 'Задача сегодня выполнена');
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
                              task.completed ? 'Готово' : 'Выполнить'),
                        ),
                      ],
                    ),
                  ],
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
        return const Icon(Icons.task, color: AppColors.accentPrimary);
      case BaseTaskType.habit:
        return const Icon(Icons.repeat, color: AppColors.accentSecondary);
      case BaseTaskType.daily:
        return const Icon(Icons.calendar_today,
            color: AppColors.accentTertiary);
    }
  }
}
