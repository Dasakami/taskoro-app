import 'package:flutter/material.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/widgets/magic_card.dart';
import 'package:taskoro/models/user_model.dart';
import 'package:percent_indicator/percent_indicator.dart';

class OtherProfileScreen extends StatelessWidget {
  final UserModel user;

  const OtherProfileScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          MagicCard(
            useGradientBorder: true,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar and Basic Info
                  Row(
                    children: [
                      // Avatar with Level Badge
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: AppColors.gradientSecondary,
                              ),
                              border: Border.all(
                                color: AppColors.accentSecondary,
                                width: 2,
                              ),
                            ),
                            child: user.avatarUrl != null
                                ? ClipOval(
                              child: Image.network(
                                user.avatarUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.accentSecondary,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                user.level.toString(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 8),
                            LinearPercentIndicator(
                              percent: user.experiencePercent / 100,
                              lineHeight: 12,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              progressColor: AppColors.accentSecondary,
                              barRadius: const Radius.circular(6),
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
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person_add),
                        label: const Text('Добавить в друзья'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentSecondary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.sports_kabaddi),
                        label: const Text('Вызвать на дуэль'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Achievements Section
          MagicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Достижения',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 8, // Demo achievements
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: AppColors.gradientSecondary,
                        ),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats Section
          MagicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статистика',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('🎯', '157', 'Выполнено задач'),
                      _buildStatItem('🔥', '${user.streak}', 'Дней подряд'),
                      _buildStatItem('🏆', '12', 'Побед в дуэлях'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
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
}