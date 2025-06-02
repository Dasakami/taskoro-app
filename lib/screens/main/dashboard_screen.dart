import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:taskoro/providers/tasks_provider.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/widgets/magic_card.dart';
import '../../providers/user_provider.dart';
import '../../widgets/task_list_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final tasksProvider = context.watch<TasksProvider>();

    final user = userProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Stats Card
          MagicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Username and Level
                  Row(
                    children: [
                      // Level Circle
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
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.level.toString(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // XP Bar
                            LinearPercentIndicator(
                              percent: user.experiencePercent / 100,
                              lineHeight: 10,
                              animation: true,
                              animationDuration: 1000,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              progressColor: AppColors.accentPrimary,
                              barRadius: const Radius.circular(10),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user.experience} / ${user.experienceNeeded} XP',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Currency
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCurrencyItem(
                        icon: '💰',
                        value: user.coins.toString(),
                        label: 'Монеты',
                      ),
                      _buildCurrencyItem(
                        icon: '💎',
                        value: user.gems.toString(),
                        label: 'Самоцветы',
                      ),
                      _buildCurrencyItem(
                        icon: '🔥',
                        value: user.streak.toString(),
                        label: 'Дней подряд',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Daily Mission Card
          if (tasksProvider.dailyMission != null)
            MagicCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Твоя миссия на сегодня',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      tasksProvider.dailyMission!.title,
                      style: const TextStyle(
                        color: AppColors.accentPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tasksProvider.dailyMission!.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildRewardItem(
                          icon: '⭐',
                          value: '${tasksProvider.dailyMission!.experienceReward} XP',
                        ),
                        const SizedBox(width: 16),
                        _buildRewardItem(
                          icon: '💰',
                          value: tasksProvider.dailyMission!.coinsReward.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Daily Quote and Progress
          Row(
            children: [
              // Motivation Quote
              Expanded(
                flex: 3,
                child: MagicCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Мотивация дня',
                          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        if (tasksProvider.dailyMotivation != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '"${tasksProvider.dailyMotivation!}"',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (tasksProvider.dailyMotivation != null)
                                Text(
                                  '— ${tasksProvider.dailyMotivation!}',
                                  style: const TextStyle(
                                    color: AppColors.accentSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Progress Circle
              Expanded(
                flex: 2,
                child: MagicCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Прогресс',
                          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CircularPercentIndicator(
                          radius: 60,
                          lineWidth: 8,
                          percent: tasksProvider.completedTasksPercentage / 100,
                          center: Text(
                            '${tasksProvider.completedTasksPercentage}%',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          progressColor: AppColors.accentPrimary,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          circularStrokeCap: CircularStrokeCap.round,
                          animation: true,
                          animationDuration: 1500,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Сегодня: ${tasksProvider.completedTasksToday}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Tasks
          MagicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Недавние задачи',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  if (tasksProvider.tasks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'У вас пока нет задач. Создайте свою первую задачу!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...tasksProvider.recentTasks.map((task) => TaskListItem(
                      task: task,
                      onToggle: () {
                        final token = userProvider.accessToken;
                        if (token != null) {
                          tasksProvider.toggleTaskStatus(task);
                        } else {
                          print('No token found');
                        }
                      },
                    )),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to tasks screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundSecondary,
                        side: const BorderSide(color: AppColors.accentPrimary),
                      ),
                      child: const Text('Все задачи'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem({
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required String icon,
    required String value,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
