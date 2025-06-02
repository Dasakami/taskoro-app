import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/tasks_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/task_card.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaskType _selectedType = TaskType.oneTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedType = TaskType.values[_tabController.index];
      });
    });

    // Fetch tasks on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshTasks() async {
    final provider = Provider.of<TasksProvider>(context, listen: false);
    await provider.fetchTasks();
    await provider.fetchCategories();
  }

  void _showCreateTaskDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          taskType: _selectedType,
          onSave: (task) async {
            final provider = Provider.of<TasksProvider>(context, listen: false);
            await provider.createTask(task);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _navigateToTaskDetail(TaskModel task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          onSave: (updatedTask) async {
            final provider = Provider.of<TasksProvider>(context, listen: false);
            await provider.updateTask(updatedTask);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _completeTask(TaskModel task) async {
    final provider = Provider.of<TasksProvider>(context, listen: false);
    await provider.toggleTaskStatus(task);

    if (!task.isCompleted) {
      _showCompletionDialog(task);
    }
  }

  void _showCompletionDialog(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            SizedBox(width: 8),
            Text('Поздравляем!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Вы выполнили задачу "${task.title}"!'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: AppColors.accentPrimary),
                      const SizedBox(width: 4),
                      Text('${task.coins}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('${task.experienceReward} XP', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отлично!'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('Удалить задачу'),
        content: Text('Вы уверены, что хотите удалить задачу "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && task.id != null) {
      final provider = Provider.of<TasksProvider>(context, listen: false);
      await provider.deleteTask(task.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<TasksProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Tab bar
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
                    gradient: const LinearGradient(colors: AppColors.gradientPrimary),
                  ),
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'Одноразовые'),
                    Tab(text: 'Привычки'),
                    Tab(text: 'Цели на день'),
                  ],
                ),
              ),

              // Error message
              if (provider.error != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(provider.error!, style: const TextStyle(color: Colors.red))),
                      IconButton(
                        onPressed: _refreshTasks,
                        icon: const Icon(Icons.refresh, color: Colors.red),
                      ),
                    ],
                  ),
                ),

              // Task lists
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshTasks,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTaskList(provider, TaskType.oneTime),
                      _buildTaskList(provider, TaskType.habit),
                      _buildTaskList(provider, TaskType.daily),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        backgroundColor: AppColors.accentPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(TasksProvider provider, TaskType type) {
    final tasks = provider.getTasksByType(type);

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTypeIcon(type),
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(type),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Нажмите + чтобы создать первую задачу',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= tasks.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => _navigateToTaskDetail(task),
          onComplete: () => _completeTask(task),
          onEdit: () => _navigateToTaskDetail(task),
          onDelete: () => _deleteTask(task),
        );
      },
    );
  }

  IconData _getTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.oneTime:
        return Icons.task_alt;
      case TaskType.habit:
        return Icons.repeat;
      case TaskType.daily:
        return Icons.today;
    }
  }

  String _getEmptyMessage(TaskType type) {
    switch (type) {
      case TaskType.oneTime:
        return 'Нет одноразовых задач';
      case TaskType.habit:
        return 'Нет привычек';
      case TaskType.daily:
        return 'Нет целей на день';
    }
  }
}