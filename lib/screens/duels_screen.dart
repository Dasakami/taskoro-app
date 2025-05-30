import 'package:flutter/material.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/widgets/magic_card.dart';

class Duel {
  final String id;
  final String opponentName;
  final String? opponentAvatar;
  final int userScore;
  final int opponentScore;
  final DateTime endDate;
  final String challenge;
  final List<String> rewards;

  Duel({
    required this.id,
    required this.opponentName,
    this.opponentAvatar,
    required this.userScore,
    required this.opponentScore,
    required this.endDate,
    required this.challenge,
    this.rewards = const [],
  });

  bool get isWinning => userScore > opponentScore;
  bool get isTied => userScore == opponentScore;
}

class DuelsScreen extends StatelessWidget {
  const DuelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for duels
    final activeDuels = [
      Duel(
        id: '1',
        opponentName: 'МегаЗадачник',
        userScore: 7,
        opponentScore: 5,
        endDate: DateTime.now().add(const Duration(days: 2)),
        challenge: 'Выполнить больше задач за неделю',
        rewards: ['50 XP', '25 монет'],
      ),
      Duel(
        id: '2',
        opponentName: 'РаннийЧемпион',
        userScore: 3,
        opponentScore: 4,
        endDate: DateTime.now().add(const Duration(days: 1)),
        challenge: 'Кто раньше встает 5 дней подряд',
        rewards: ['40 XP', '20 монет'],
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Активные Дуэли',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),

          if (activeDuels.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'У вас нет активных дуэлей',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...activeDuels.map((duel) => DuelCard(duel: duel)),

          const SizedBox(height: 24),

          Text(
            'Бросить вызов',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),

          const ChallengeCard(),
        ],
      ),
    );
  }
}

class DuelCard extends StatelessWidget {
  final Duel duel;

  const DuelCard({
    super.key,
    required this.duel,
  });

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = duel.endDate.difference(DateTime.now()).inDays;

    return MagicCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duel Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientSecondary,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sports_kabaddi,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Дуэль с ${duel.opponentName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
                  child: Text(
                    'Осталось $daysLeft дн.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Duel Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  duel.challenge,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Score display
                Row(
                  children: [
                    // Player score
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Вы',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: AppColors.gradientPrimary,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentPrimary.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                duel.userScore.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // VS label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          color: AppColors.accentSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Opponent score
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            duel.opponentName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.backgroundSecondary,
                              border: Border.all(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                duel.opponentScore.toString(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: duel.isWinning
                        ? AppColors.accentPrimary.withOpacity(0.1)
                        : duel.isTied
                        ? Colors.grey.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: duel.isWinning
                          ? AppColors.accentPrimary.withOpacity(0.3)
                          : duel.isTied
                          ? Colors.grey.withOpacity(0.3)
                          : AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    duel.isWinning
                        ? 'Вы лидируете!'
                        : duel.isTied
                        ? 'Ничья, борьба продолжается!'
                        : 'Соперник впереди, нужно поднажать!',
                    style: TextStyle(
                      color: duel.isWinning
                          ? AppColors.accentPrimary
                          : duel.isTied
                          ? AppColors.textSecondary
                          : AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Rewards
                const Text(
                  'Награда победителю:',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: duel.rewards.map((reward) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accentSecondary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      reward,
                      style: TextStyle(
                        color: AppColors.accentSecondary.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  )).toList(),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentSecondary,
                    ),
                    child: const Text('Выполнить задачу'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final challenges = [
      'Утренняя зарядка 7 дней подряд',
      'Чтение 20 страниц в день',
      'Медитация 10 минут ежедневно',
      'Выполнение 5 задач в день',
      'Отказ от вредной еды на неделю',
    ];

    final friends = [
      {'name': 'МегаЗадачник', 'level': 8},
      {'name': 'РаннийЧемпион', 'level': 6},
      {'name': 'ДисциплинаПро', 'level': 5},
    ];

    return MagicCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Создать новую дуэль',
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Select challenge
            const Text(
              'Выберите испытание:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
                color: Colors.black12,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text(
                    'Выберите испытание',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  dropdownColor: AppColors.backgroundSecondary,
                  items: challenges.map((challenge) {
                    return DropdownMenuItem<String>(
                      value: challenge,
                      child: Text(
                        challenge,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Select opponent
            const Text(
              'Выберите соперника:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            ...friends.map((friend) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: AppColors.gradientSecondary,
                  ),
                ),
                child: Center(
                  child: Text(
                    (friend['name'] as String).substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                friend['name'] as String,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                'Уровень: ${friend['level']}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              trailing: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accentSecondary),
                ),
                child: const Text(
                  'Вызвать',
                  style: TextStyle(color: AppColors.accentSecondary),
                ),
              ),
            )),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search),
                label: const Text('Найти больше соперников'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accentPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

