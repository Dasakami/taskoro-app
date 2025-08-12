import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:taskoro/screens/friends/friends_screen.dart';
import 'package:taskoro/screens/history_screen.dart';
import 'package:taskoro/screens/profile_screen.dart';
import 'package:taskoro/screens/settings_screen.dart';
import 'package:taskoro/screens/shop/chests_screen.dart';
import 'package:taskoro/screens/shop/inventory_screen.dart';
import 'package:taskoro/screens/shop/shop_home_screen.dart';
import 'package:taskoro/theme/app_theme.dart';

import '../screens/achivements_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/tasks/base_task_screen.dart';
import '../screens/tasks/tasks_screen.dart';

class AppDrawer extends StatelessWidget {
  final void Function(Widget screen, String title) onNavigate;

  const AppDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final userProvider = context.read<UserProvider>();

    if (user == null) {
      return const Drawer(child: Center(child: CircularProgressIndicator()));
    }

    return Drawer(
      backgroundColor: AppColors.backgroundSecondary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientPrimary,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => onNavigate(const ProfileScreen(), 'Профиль'),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: user.avatarUrl != null
                              ? Image.network(
                                  user.avatarUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey.shade800,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 40,
                                  ),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Уровень: ${user.level}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // User stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('💰', user.coins.toString()),
                    _buildStatItem('💎', user.gems.toString()),
                  ],
                ),
              ],
            ),
          ),

          // Menu items
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Главная',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.check_box,
            title: 'Задачи',
            onTap: () => onNavigate(const TasksScreen(), 'Задачи'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.widgets,
            title: 'Базовые задачи',
            onTap: () => onNavigate(const BaseTaskScreen(), 'Базовые задачи'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people_alt,
            title: 'Друзья',
            onTap: () => onNavigate(const FriendsScreen(), 'Друзья'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.military_tech,
            title: 'Достижения',
            onTap: () => onNavigate(const AchievementsScreen(), 'Достижения'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.shopping_cart,
            title: 'Магазин',
            onTap: () => onNavigate(const ShopHomeScreen(), 'Магазин'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.history,
            title: 'История',
            onTap: () => onNavigate(const HistoryScreen(), 'История'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.note_alt,
            title: 'Заметки',
            onTap: () => onNavigate(const NotesScreen(), 'Заметки'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Настройки',
            onTap: () => onNavigate(const SettingsScreen(), 'Настройки'),
          ),

          const Divider(color: AppColors.border),

          // Logout
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Выйти',
            textColor: AppColors.accentSecondary,
            onTap: () {
              userProvider.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? AppColors.textPrimary),
      ),
      onTap: onTap,
    );
  }
}
