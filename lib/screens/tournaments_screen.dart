import 'package:flutter/material.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/widgets/magic_card.dart';

class Tournament {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int participants;
  final List<String> rewards;

  Tournament({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.participants = 0,
    this.rewards = const [],
  });
}

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for tournaments
    final tournaments = [
      Tournament(
        id: '1',
        title: 'Недельный Челлендж Продуктивности',
        description: 'Выполняйте по 5 задач в день в течение недели и получите особые награды!',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        participants: 126,
        rewards: ['300 XP', '150 монет', 'Титул "Мастер Продуктивности"'],
      ),
      Tournament(
        id: '2',
        title: 'Марафон Ранних Подъемов',
        description: 'Вставайте каждый день до 7 утра в течение 10 дней',
        startDate: DateTime.now().add(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 13)),
        participants: 78,
        rewards: ['250 XP', '120 монет', 'Значок "Ранняя Птица"'],
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Текущие Турниры',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),

          if (tournaments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Нет активных турниров на данный момент',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...tournaments.map((tournament) => TournamentCard(tournament: tournament)),

          const SizedBox(height: 32),

          Text(
            'Лидеры Месяца',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),

          const LeaderboardCard(),
        ],
      ),
    );
  }
}

class TournamentCard extends StatelessWidget {
  final Tournament tournament;

  const TournamentCard({
    super.key,
    required this.tournament,
  });

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isActive = tournament.startDate.isBefore(now) && tournament.endDate.isAfter(now);
    final isUpcoming = tournament.startDate.isAfter(now);

    return MagicCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [
              AppColors.backgroundSecondary,
              Color.alphaBlend(
                Colors.purple.withOpacity(0.15),
                AppColors.backgroundSecondary,
              ),
            ]
                : [
              AppColors.backgroundSecondary,
              AppColors.backgroundSecondary,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? AppColors.gradientPrimary
                      : isUpcoming
                      ? [Colors.grey.shade800, Colors.grey.shade700]
                      : [Colors.grey.shade900, Colors.grey.shade800],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isActive
                          ? Icons.emoji_events
                          : isUpcoming
                          ? Icons.hourglass_empty
                          : Icons.history,
                      color: isActive
                          ? AppColors.warning
                          : AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive
                              ? 'Активен до ${_formatDate(tournament.endDate)}'
                              : isUpcoming
                              ? 'Начинается ${_formatDate(tournament.startDate)}'
                              : 'Завершен ${_formatDate(tournament.endDate)}',
                          style: TextStyle(
                            color: isActive
                                ? AppColors.accentTertiary
                                : Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tournament.participants.toString(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tournament Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Награды:',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tournament.rewards.map((reward) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentPrimary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        reward,
                        style: TextStyle(
                          color: AppColors.accentPrimary.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isActive || isUpcoming ? () {} : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? AppColors.accentPrimary
                            : Colors.grey.shade800,
                      ),
                      child: Text(
                        isActive
                            ? 'Участвовать'
                            : isUpcoming
                            ? 'Напомнить'
                            : 'Завершен',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock leaderboard data
    final leaderboardEntries = [
      {'username': 'СуперГерой', 'points': 1230, 'rank': 1},
      {'username': 'ПродуктивныйГений', 'points': 980, 'rank': 2},
      {'username': 'МастерЗадач', 'points': 870, 'rank': 3},
      {'username': 'РаннийЧемпион', 'points': 760, 'rank': 4},
      {'username': 'ДисциплинаПро', 'points': 650, 'rank': 5},
    ];

    return MagicCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.leaderboard,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Таблица лидеров',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Апрель 2025',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaderboardEntries.length,
            itemBuilder: (context, index) {
              final entry = leaderboardEntries[index];
              final rank = entry['rank'] as int;

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  border: index < leaderboardEntries.length - 1
                      ? const Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 0.5,
                    ),
                  )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: rank == 1
                            ? const Color(0xFFFFD700)
                            : rank == 2
                            ? const Color(0xFFC0C0C0)
                            : rank == 3
                            ? const Color(0xFFCD7F32)
                            : Colors.grey.shade800,
                      ),
                      child: Center(
                        child: Text(
                          rank.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        entry['username'] as String,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${entry['points']} очков',
                      style: const TextStyle(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accentPrimary),
                ),
                child: const Text('Полная таблица'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}