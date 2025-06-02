import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/duel_model.dart';
import '../../../theme/app_theme.dart';

class DuelDetailScreen extends StatelessWidget {
  final DuelModel duel;

  const DuelDetailScreen({Key? key, required this.duel}) : super(key: key);

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool duelEnded = duel.endTime != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("⚔️ Дуэль"),
        backgroundColor: AppColors.cardBackground,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
              )
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "${duel.challenger.username}  VS  ${duel.opponent.username}",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              _infoRow(Icons.attach_money, 'Ставка', '${duel.coinsStake} монет'),
              _infoRow(Icons.info_outline, 'Статус', duel.status),
              _infoRow(Icons.timer_outlined, 'Создана', _formatDateTime(duel.createdAt)),
              _infoRow(Icons.play_circle_outline, 'Началась', _formatDateTime(duel.startTime)),
              _infoRow(Icons.flag_outlined, 'Завершилась', _formatDateTime(duel.endTime)),

              if (duelEnded)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          duel.winner == null
                              ? 'Победитель не определён'
                              : 'Победитель: ${duel.winner == duel.challenger.id ? duel.challenger.username : duel.opponent.username}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              Row(
                children: const [
                  Icon(Icons.book, size: 20, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text(
                    'ID задачи:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              Text(
                '${duel.task}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Подробнее о задаче можно загрузить позже...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPrimary, size: 20),
          const SizedBox(width: 12),
          Text(
            '$title:',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
