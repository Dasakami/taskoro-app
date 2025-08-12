import 'package:flutter/material.dart';
import 'package:taskoro/screens/main/privacy_policy_page.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/widgets/magic_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Настройки',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),

          MagicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Общие настройки',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: AppColors.accentPrimary),
                    title: const Text(
                      'Уведомления',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: AppColors.accentPrimary,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode, color: AppColors.accentSecondary),
                    title: const Text(
                      'Темная тема',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: AppColors.accentSecondary,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language, color: AppColors.accentTertiary),
                    title: const Text(
                      'Язык',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: DropdownButton<String>(
                      value: 'Русский',
                      items: const [
                        DropdownMenuItem(
                          value: 'Русский',
                          child: Text('Русский'),
                        ),
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English'),
                        ),
                      ],
                      onChanged: (value) {},
                      dropdownColor: AppColors.backgroundSecondary,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          MagicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Аккаунт',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person, color: AppColors.accentPrimary),
                    title: const Text(
                      'Редактировать профиль',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
                    onTap: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: AppColors.error),
                    title: const Text(
                      'Удалить аккаунт',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      // Show confirmation dialog
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          MagicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'О приложении',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info, color: AppColors.accentTertiary),
                    title: const Text(
                      'Версия',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: const Text(
                      '1.0.0',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description, color: AppColors.accentPrimary),
                    title: const Text(
                      'Лицензии',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LicensePage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: AppColors.accentSecondary),
                    title: const Text(
                      'Политика конфиденциальности',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}