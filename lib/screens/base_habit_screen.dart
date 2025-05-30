import 'package:flutter/material.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/widgets/magic_card.dart';

class BaseHabitScreen extends StatelessWidget {
  const BaseHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Базовые привычки',
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
                    'Доступные привычки',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.repeat, color: AppColors.accentSecondary),
                      title: Text(
                        'Привычка ${index + 1}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        'Описание привычки ${index + 1}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentSecondary,
                        ),
                        child: const Text('Добавить'),
                      ),
                    ),
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