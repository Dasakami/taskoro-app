import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/base_daily_provider.dart';
import '../../models/base_task.dart';
import '../../widgets/magic_card.dart';
import '../../widgets/state_wrapper.dart';
import '../../theme/app_theme.dart';

class BaseDailyScreen extends StatelessWidget {
  static const routeName = '/base-dailies';
  const BaseDailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BaseDailyProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!prov.loading && prov.dailies.isEmpty && prov.error == null) {
        prov.fetch();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Базовые ежедневки')),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : prov.error != null
          ? Center(child: Text(prov.error!))
          : RefreshIndicator(
        onRefresh: prov.fetch,
        child: prov.dailies.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            Center(child: Text('Нет доступных ежедневок')),
          ],
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: prov.dailies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final task = prov.dailies[i];
            return MagicCard(
              child: ListTile(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/base-daily-detail',
                  arguments: task,
                ),
                leading: const Icon(Icons.calendar_today,
                    color: AppColors.accentTertiary),
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
                    if (ok) {
                      AppSnackBar.showSuccess(context, message: 'Получено ${task.xpReward} XP');
                    } else {
                      AppSnackBar.showError(context, 'Ошибка');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.accentTertiary),
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
