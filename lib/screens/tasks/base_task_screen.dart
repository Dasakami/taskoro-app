import 'package:flutter/material.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/widgets/magic_card.dart';

class BaseTaskScreen extends StatelessWidget {
  const BaseTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Базовые задачи',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),

          // One-time tasks section
          MagicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Одноразовые задачи',
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
                    itemCount: 3,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.task_alt, color: AppColors.accentPrimary),
                      title: Text(
                        'Базовая задача ${index + 1}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        'Описание базовой задачи ${index + 1}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Добавить'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/base-habits');
                },
                icon: const Icon(Icons.repeat),
                label: const Text('Привычки'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentSecondary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/base-daily');
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Цели на день'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}