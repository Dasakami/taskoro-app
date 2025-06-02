import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import 'magic_card.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return MagicCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (showActions) ...[
                    _buildStatusIndicator(),
                    const SizedBox(width: 8),
                    _buildActionButtons(context),
                  ],
                ],
              ),

              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: task.isCompleted ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Task info chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.star,
                    task.difficultyName,
                    task.difficultyColor,
                  ),
                  _buildInfoChip(
                    Icons.category,
                    _getTypeLabel(task.type),
                    _getTypeColor(task.type),
                  ),
                  if (task.coins > 0)
                    _buildInfoChip(
                      Icons.monetization_on,
                      '${task.coins}',
                      AppColors.accentPrimary,
                    ),
                  if (task.streak > 0)
                    _buildInfoChip(
                      Icons.local_fire_department,
                      '${task.streak}',
                      Colors.orange,
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Date and status info
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.createdAt.toLocal().toString().split(' ').first,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: task.statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      task.statusName,
                      style: TextStyle(
                        color: task.statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    IconData icon;
    Color color;

    switch (task.status) {
      case TaskStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case TaskStatus.inProgress:
        icon = Icons.play_circle;
        color = Colors.blue;
        break;
      case TaskStatus.paused:
        icon = Icons.pause_circle;
        color = Colors.orange;
        break;
      default:
        icon = Icons.radio_button_unchecked;
        color = AppColors.textSecondary;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildActionButtons(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      onSelected: (value) {
        switch (value) {
          case 'complete':
            onComplete?.call();
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (!task.isCompleted)
          const PopupMenuItem(
            value: 'complete',
            child: Row(
              children: [
                Icon(Icons.check, color: Colors.green),
                SizedBox(width: 8),
                Text('Выполнить'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: AppColors.textPrimary),
              SizedBox(width: 8),
              Text('Редактировать'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Удалить'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.oneTime:
        return 'Одноразовая';
      case TaskType.habit:
        return 'Привычка';
      case TaskType.daily:
        return 'Цель на день';
    }
  }

  Color _getTypeColor(TaskType type) {
    switch (type) {
      case TaskType.oneTime:
        return Colors.blue;
      case TaskType.habit:
        return Colors.purple;
      case TaskType.daily:
        return Colors.teal;
    }
  }
}