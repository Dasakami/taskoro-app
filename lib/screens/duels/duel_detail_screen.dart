import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/duel_model.dart';
import '../../providers/duel_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class DuelDetailScreen extends StatelessWidget {
  static const routeName = '/duel-detail';

  const DuelDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final d = ModalRoute.of(context)!.settings.arguments as DuelModel;
    final token = context.read<UserProvider>().accessToken;
    final prov  = context.read<DuelProvider>();

    // Формат дат
    String fmt(DateTime? dt) => dt == null ? '-' : DateFormat('dd.MM.yyyy HH:mm').format(dt);

    Color badgeColor;
    switch (d.status) {
      case 'pending': badgeColor = AppColors.warning; break;
      case 'active':  badgeColor = AppColors.accentPrimary; break;
      case 'declined':badgeColor = AppColors.error; break;
      default:        badgeColor = AppColors.success;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Дуэль #${d.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('#${d.id}', style: AppTheme.darkTheme.textTheme.displaySmall)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
              child: Text(d.status.toUpperCase(), style: AppTheme.darkTheme.textTheme.bodyMedium),
            )
          ]),
          const SizedBox(height: 12),

          _infoRow(Icons.account_circle, 'Challenger:', d.challenger.username),
          _infoRow(Icons.person, 'Opponent:',   d.opponent.username),
          _infoRow(Icons.task_alt,      'Task ID:',   d.task?.toString() ?? '-'),
          _infoRow(Icons.monetization_on, 'Stake:',   '${d.coinsStake}'),
          _infoRow(Icons.calendar_today, 'Created:', fmt(d.createdAt)),
          _infoRow(Icons.play_arrow,    'Started:',  fmt(d.startTime)),
          _infoRow(Icons.stop_circle,   'Finished:', fmt(d.endTime)),
          if (d.winner != null)
            _infoRow(Icons.emoji_events, 'Winner:',
                d.winner == d.challenger.id ? d.challenger.username : d.opponent.username),

          const Spacer(),
          if (d.status == 'pending')
            Row(children: [
              ElevatedButton(
                onPressed: () => prov.acceptDuel(d.id),
                child: const Text('Принять'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => prov.declineDuel(d.id),
                child: const Text('Отклонить'),
              ),
            ]),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData ico, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(ico, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: AppTheme.darkTheme.textTheme.bodyLarge),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: AppTheme.darkTheme.textTheme.bodyMedium)),
      ]),
    );
  }
}
