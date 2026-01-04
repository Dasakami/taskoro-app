import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/widgets/magic_card.dart';
import 'package:taskoro/providers/user_provider.dart';

import '../providers/achievement_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    final achievementsProvider = Provider.of<AchievementProvider>(context, listen: false);
    await achievementsProvider.fetchAchievements();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final achievementsProvider = Provider.of<AchievementProvider>(context);

    final total = achievementsProvider.totalCount;
    final acquired = achievementsProvider.acquiredCount;
    final achievements = achievementsProvider.achievements;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Достижения',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          MagicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Прогресс достижений',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : acquired / total,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$acquired из $total достижений получено',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return MagicCard(
                color: achievement.isAcquired
                    ? AppColors.gradientPrimary.first.withOpacity(0.9)
                    : Colors.grey.shade800,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: achievement.isAcquired
                              ? const LinearGradient(
                            colors: AppColors.gradientPrimary,
                          )
                              : null,
                          color: achievement.isAcquired
                              ? null
                              : Colors.grey.shade700,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          achievement.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        achievement.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (achievement.isAcquired) ...[
                            const Icon(
                              Icons.emoji_events,
                              color: AppColors.accentPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${achievement.experienceReward} XP',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else
                            const Text(
                              'Не получено',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
