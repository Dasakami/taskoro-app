import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/tasks_provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:taskoro/widgets/magic_card.dart';
import 'package:taskoro/widgets/task_list_item.dart';
import 'package:taskoro/models/task_model.dart';
import 'package:taskoro/theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: AppColors.gradientPrimary,
                ),
              ),
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Базовые задачи'),
                Tab(text: 'Привычки'),
                Tab(text: 'Цели на день'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                BasicTasksTab(),
                HabitsTab(),
                DailyGoalsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add task dialog based on current tab
          _showAddTaskDialog(_tabController.index);
        },
        backgroundColor: AppColors.accentPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(int tabIndex) {
    // Implement dialog for adding tasks based on tab
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          tabIndex == 0 ? 'Новая задача' :
          tabIndex == 1 ? 'Новая привычка' : 'Новая цель',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add form fields based on task type
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add task logic
              Navigator.of(context).pop();
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}

class BasicTasksTab extends StatelessWidget {
  const BasicTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MagicCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Базовые задачи',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                // List of basic tasks
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HabitsTab extends StatelessWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MagicCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Привычки',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                // List of habits
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DailyGoalsTab extends StatelessWidget {
  const DailyGoalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MagicCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Цели на день',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                // List of daily goals
              ],
            ),
          ),
        ),
      ],
    );
  }
}