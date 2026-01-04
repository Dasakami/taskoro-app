import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tournaments_provider.dart';
import '../models/participant.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  static const routeName = '/leaderboard';

  @override
  Widget build(BuildContext context) {
    // tournamentId передаётся через arguments
    final tournamentId = ModalRoute.of(context)!.settings.arguments as int;
    final tourProv = Provider.of<TournamentsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Лидерборд')),
      body: FutureBuilder<dynamic>(
        future: tourProv.fetchLeaderboard(tournamentId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Ошибка: ${snap.error}', style: AppTheme.darkTheme.textTheme.bodyLarge),
            );
          }
          final data = snap.data;
          if (data == null || (data is List && data.isEmpty)) {
            return Center(child: Text('Нет участников', style: AppTheme.darkTheme.textTheme.bodyLarge));
          }
          
          List<dynamic> list = data is List ? data : [];
          if (list.isEmpty) return Center(child: Text('Нет участников', style: AppTheme.darkTheme.textTheme.bodyLarge));
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const Divider(color: AppColors.border),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final item = list[i];
              final p = item is Map ? Participant.fromJson(item as Map<String, dynamic>) : item as Participant;
              return ListTile(
                tileColor: AppColors.backgroundSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(p.username, style: AppTheme.darkTheme.textTheme.bodyLarge),
                subtitle: Text(
                  'Очки: ${p.score} • Вып: ${p.tasksCompleted}',
                  style: AppTheme.darkTheme.textTheme.bodyMedium,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
