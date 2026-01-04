import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/tournaments_model.dart';
import '../providers/tournaments_provider.dart';
import '../screens/leaderboard_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/state_wrapper.dart';

class TournamentDetailScreen extends StatelessWidget {
  static const routeName = '/tournament-detail';

  const TournamentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ModalRoute.of(context)!.settings.arguments as Tournament;
    final prov = Provider.of<TournamentsProvider>(context, listen: false);

    // Форматирование дат
    final start = DateFormat('dd MMMM yyyy, HH:mm').format(t.startDate);
    final end   = DateFormat('dd MMMM yyyy, HH:mm').format(t.endDate);

    // Статус + цвет бейджа
    String status;
    Color badgeColor;
    if (t.isActive) {
      status = 'Активен';
      badgeColor = AppColors.success;
    } else if (t.startDate.isAfter(DateTime.now())) {
      status = 'Предстоящий';
      badgeColor = AppColors.warning;
    } else {
      status = 'Завершён';
      badgeColor = AppColors.border;
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Название + статус
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.title,
                    style: AppTheme.darkTheme.textTheme.displayMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(status,
                      style: AppTheme.darkTheme.textTheme.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Даты старта и окончания
            Row(
              children: [
                const Icon(Icons.play_circle_fill,
                    color: AppColors.accentPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Старт: $start',
                      style: AppTheme.darkTheme.textTheme.bodyLarge),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.stop_circle_outlined,
                    color: AppColors.accentSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Конец: $end',
                      style: AppTheme.darkTheme.textTheme.bodyLarge),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Описание
            Text('Описание:',
                style: AppTheme.darkTheme.textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(t.description,
                style: AppTheme.darkTheme.textTheme.bodyMedium),
            const SizedBox(height: 24),

            // 4. Награды
            Text('Награды:',
                style: AppTheme.darkTheme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _RewardIcon(
                    icon: Icons.flash_on,
                    label: '${t.experienceReward} XP'),
                _RewardIcon(
                    icon: Icons.monetization_on,
                    label: '${t.coinsReward} Coins'),
                _RewardIcon(
                    icon: Icons.diamond,
                    label: '${t.gemsReward} Gems'),
              ],
            ),
            const SizedBox(height: 24),

            // 5. Минимум задач
            Text('Мин. задач для участия:',
                style: AppTheme.darkTheme.textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text('${t.minTasksCompleted}',
                style: AppTheme.darkTheme.textTheme.bodyMedium),

            const SizedBox(height: 32),

            // 6. Кнопки действия
            Row(
              children: [
                if (t.isActive)
                  ElevatedButton(
                    onPressed: () async {
                        try {
                        await prov.joinTournament(t.id);
                        AppSnackBar.showSuccess(context, message: 'Успешно присоединились');
                      } catch (e) {
                        AppSnackBar.showError(context, 'Ошибка: $e');
                      }
                    },
                    child: const Text('Присоединиться'),
                  ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: t.isActive || t.startDate.isBefore(DateTime.now())
                      ? () {
                    Navigator.of(context).pushNamed(
                      LeaderboardScreen.routeName,
                      arguments: t.id,
                    );
                  }
                      : null,
                  child: const Text('Лидерборд'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Вспомогательный виджет для отображения иконки + подписи
class _RewardIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _RewardIcon({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentTertiary, size: 32),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.darkTheme.textTheme.bodyMedium),
      ],
    );
  }
}