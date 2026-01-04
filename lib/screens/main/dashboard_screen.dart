import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/widgets/magic_card.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/task_list_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final tasksProvider = context.read<TasksProvider>();
      final userProvider = context.read<UserProvider>();

      await Future.wait([
        tasksProvider.fetchTasks(),
        userProvider.refreshMainData(),
      ]);
    } catch (e) {
      debugPrint('Ошибка загрузки данных: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, TasksProvider>(
      builder: (context, userProvider, tasksProvider, child) {
        final user = userProvider.user;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Правильно вычисляем процент прогресса
        final progressPercent = tasksProvider.completedTasksPercentage;

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Stats Card
                MagicCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(fontSize: 20),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearPercentIndicator(
                                    percent: (user.experience / user.experienceNeeded).clamp(0.0, 1.0),
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

                // Daily Mission
                if (userProvider.dailyMission != null)
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
                            userProvider.dailyMission!.title,
                            style: const TextStyle(
                              color: AppColors.accentPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userProvider.dailyMission!.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildRewardItem(
                                icon: '⭐',
                                value: '${userProvider.dailyMission!.experienceReward} XP',
                              ),
                              const SizedBox(width: 16),
                              _buildRewardItem(
                                icon: '💰',
                                value: userProvider.dailyMission!.coinsReward.toString(),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(fontSize: 16),
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              if (userProvider.dailyMotivation != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '"${userProvider.dailyMotivation!.text}"',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '— ${userProvider.dailyMotivation!.author}',
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

                    // Progress Circle - ИСПРАВЛЕНО
                    Expanded(
                      flex: 2,
                      child: MagicCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Прогресс',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              CircularPercentIndicator(
                                radius: 60,
                                lineWidth: 8,
                                percent: (progressPercent / 100).clamp(0.0, 1.0),
                                center: Text(
                                  '${progressPercent.toStringAsFixed(0)}%',
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
                                'Сегодня: ${tasksProvider.completedTasksToday.length}',
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

                // Recent Tasks - ИСПРАВЛЕНО
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

                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (!tasksProvider.isInitialized)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Загрузка задач...',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          )
                        else if (tasksProvider.tasks.isEmpty)
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
                                onToggle: () async {
                                  await tasksProvider.completeTaskById(task.id!);
                                },
                              )),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to tasks screen
                              DefaultTabController.of(context)?.animateTo(1);
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
          ),
        );
      },
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