import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/widgets/magic_card.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (userProvider.isAuthenticated == false) {
      return const Center(child: Text('Пожалуйста, войдите в систему'));
    }

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Динамический фон в зависимости от надетого предмета
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _getBackgroundImage(user),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Профиль с аватаром
                  MagicCard(
                    useGradientBorder: true,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: AppColors.gradientPrimary,
                                    ),
                                    border: Border.all(
                                      color: _getAvatarFrameColor(user),
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
                                        color: AppColors.accentPrimary,
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.username,
                                    style:
                                    Theme.of(context).textTheme.displaySmall,
                                  ),
                                  if (user.title != null && user.title!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentPrimary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.accentPrimary,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        user.title!,
                                        style: const TextStyle(
                                          color: AppColors.accentPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  LinearPercentIndicator(
                                    percent: user.experiencePercent / 100,
                                    lineHeight: 12,
                                    backgroundColor:
                                    Colors.white.withOpacity(0.1),
                                    progressColor: AppColors.accentPrimary,
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
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Статистика монеты, самоцветы, серия
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('💰', user.coins.toString(), 'Монеты'),
                      _buildStatItem('💎', user.gems.toString(), 'Самоцветы'),
                      _buildStatItem('🔥', '${user.streak} дн.', 'Серия'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// Медали
                  if (user.medals.isNotEmpty)
                    MagicCard(
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Медали',
                                  style:
                                  Theme.of(context).textTheme.displaySmall),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: user.medals.map<Widget>((medal) {
                                    IconData icon;
                                    Color color;

                                    switch (medal['medal_type']) {
                                      case 'gold':
                                        icon = Icons.emoji_events;
                                        color = Colors.amber;
                                        break;
                                      case 'silver':
                                        icon = Icons.emoji_events;
                                        color = Colors.grey;
                                        break;
                                      case 'bronze':
                                        icon = Icons.emoji_events;
                                        color = Colors.brown;
                                        break;
                                      default:
                                        icon = Icons.emoji_events_outlined;
                                        color = Colors.white;
                                    }

                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: color,
                                          child: Icon(icon, color: Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          medal['name'],
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  /// Классы персонажа
                  if (user.characterClasses.isNotEmpty)
                    MagicCard(
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Класс персонажа',
                                  style:
                                  Theme.of(context).textTheme.displaySmall),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 12,
                                  children:
                                  user.characterClasses.map<Widget>((charClass) {
                                    return Chip(
                                      backgroundColor: Color(int.parse(
                                          '0xff${charClass['color'].substring(1)}')),
                                      label: Text('${charClass['icon']} ${charClass['name']}',
                                          style:
                                          const TextStyle(color: Colors.white)),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  /// Биография
                  if (user.bio != null && user.bio!.isNotEmpty)
                    MagicCard(
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('О себе',
                                  style:
                                  Theme.of(context).textTheme.displaySmall),
                              const SizedBox(height: 8),
                              Text(
                                user.bio!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Вспомогательные методы для получения динамических данных
  ImageProvider _getBackgroundImage(user) {
    // Логика для выбора фона в зависимости от надетого предмета
    // Например, если у пользователя есть определенный фон, возвращаем его
    if (user.equippedBackground != null) {
      return NetworkImage(user.equippedBackground!);
    }
    // Если фон не надет, возвращаем фон по умолчанию
    return const AssetImage('assets/images/profile_background.jpg');
  }

  Color _getAvatarFrameColor(user) {
    // Логика для выбора цвета рамки аватара в зависимости от надетого предмета
    // Например, если у пользователя есть определенная рамка, возвращаем ее цвет
    if (user.equippedAvatarFrameColor != null) {
      return Color(int.parse('0xff${user.equippedAvatarFrameColor!.substring(1)}'));
    }
    // Если рамка не надета, возвращаем цвет по умолчанию
    return AppColors.accentPrimary;
  }



  Widget _buildStatItem(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
