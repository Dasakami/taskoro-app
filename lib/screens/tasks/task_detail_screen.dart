import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/tasks_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel? task;
  final TaskType? taskType;
  final Function(TaskModel) onSave;

  const TaskDetailScreen({
    super.key,
    this.task,
    this.taskType,
    required this.onSave,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coinsController = TextEditingController();
  final _estimatedMinutesController = TextEditingController();

  TaskType _selectedType = TaskType.oneTime;
  TaskDifficulty _selectedDifficulty = TaskDifficulty.easy;
  TaskStatus _selectedStatus = TaskStatus.notStarted;
  DateTime? _selectedDeadline;
  DateTime? _selectedTargetDate;
  int? _selectedCategoryId;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coinsController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    if (_isEditing) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _coinsController.text = task.coins.toString();
      _estimatedMinutesController.text = task.estimatedMinutes?.toString() ?? '';
      _selectedType = task.type;
      _selectedDifficulty = task.difficulty;
      _selectedStatus = task.status;
      _selectedDeadline = task.deadline;
      _selectedTargetDate = task.targetDate;
      _selectedCategoryId = task.categoryId;
    } else {
      _selectedType = widget.taskType ?? TaskType.oneTime;
      _coinsController.text = '10';
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDeadline) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.accentPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeadline) {
          _selectedDeadline = picked;
        } else {
          _selectedTargetDate = picked;
        }
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final task = TaskModel(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _selectedType,
      difficulty: _selectedDifficulty,
      status: _selectedStatus,
      deadline: _selectedDeadline,
      createdAt: widget.task?.createdAt ?? now,
      updatedAt: now,
      categoryId: _selectedCategoryId,
      coins: int.tryParse(_coinsController.text) ?? 0,
      estimatedMinutes: int.tryParse(_estimatedMinutesController.text),
      targetDate: _selectedTargetDate,
      streak: widget.task?.streak ?? 0,
      lastCompleted: widget.task?.lastCompleted,
    );

    widget.onSave(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать задачу' : 'Создать задачу'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              _isEditing ? 'Сохранить' : 'Создать',
              style: const TextStyle(
                color: AppColors.accentPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info Section
            MagicCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Основная информация',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название задачи',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите название задачи';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание (необязательно)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Task Properties Section
            MagicCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Свойства задачи',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Task Type
                    DropdownButtonFormField<TaskType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Тип задачи',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: _isEditing ? null : (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Difficulty
                    DropdownButtonFormField<TaskDifficulty>(
                      value: _selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: 'Сложность',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskDifficulty.values.map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(difficulty),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_getDifficultyLabel(difficulty)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value!;
                        });
                      },
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 16),

                      // Status (only for editing)
                      DropdownButtonFormField<TaskStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Статус',
                          border: OutlineInputBorder(),
                        ),
                        items: TaskStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusLabel(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Rewards & Settings Section
            MagicCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Награды и настройки',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _coinsController,
                            decoration: const InputDecoration(
                              labelText: 'Монеты',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monetization_on),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите количество монет';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Введите число';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _estimatedMinutesController,
                            decoration: const InputDecoration(
                              labelText: 'Время (мин)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Dates Section
            MagicCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Временные рамки',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Deadline
                    if (_selectedType == TaskType.oneTime)
                      _buildDateSelector(
                        'Дедлайн',
                        _selectedDeadline,
                            () => _selectDate(context, true),
                        Icons.event,
                      ),

                    // Target Date for daily tasks
                    if (_selectedType == TaskType.daily) ...[
                      if (_selectedType == TaskType.oneTime) const SizedBox(height: 16),
                      _buildDateSelector(
                        'Целевая дата',
                        _selectedTargetDate,
                            () => _selectDate(context, false),
                        Icons.flag,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  date != null
                      ? '${date.day}.${date.month}.${date.year}'
                      : 'Не выбрано',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (date != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    if (label == 'Дедлайн') {
                      _selectedDeadline = null;
                    } else {
                      _selectedTargetDate = null;
                    }
                  });
                },
                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.oneTime:
        return 'Одноразовая задача';
      case TaskType.habit:
        return 'Привычка';
      case TaskType.daily:
        return 'Цель на день';
    }
  }

  String _getDifficultyLabel(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 'Легкая';
      case TaskDifficulty.medium:
        return 'Средняя';
      case TaskDifficulty.hard:
        return 'Сложная';
      case TaskDifficulty.epic:
        return 'Эпическая';
    }
  }

  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return const Color(0xFF33FF99);
      case TaskDifficulty.medium:
        return const Color(0xFFFFCC33);
      case TaskDifficulty.hard:
        return const Color(0xFFFF3366);
      case TaskDifficulty.epic:
        return const Color(0xFF6633FF);
    }
  }

  String _getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return 'Не начата';
      case TaskStatus.inProgress:
        return 'В процессе';
      case TaskStatus.completed:
        return 'Завершена';
      case TaskStatus.paused:
        return 'Приостановлена';
    }
  }
}