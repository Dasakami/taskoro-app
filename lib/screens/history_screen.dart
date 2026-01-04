import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/activity_log_provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:taskoro/widgets/magic_card.dart';
import 'package:taskoro/theme/app_theme.dart';

import '../models/activity_log_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ActivityLogProvider>(context, listen: false).fetchLogs();
  }

  void _onFilterSelect(String type) {
    final provider = Provider.of<ActivityLogProvider>(context, listen: false);
    provider.fetchLogs();
  }

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<ActivityLogProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('История', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Все', ''),
                _buildFilterChip('Задачи', 'class_task_complete'),
                _buildFilterChip('Достижения', 'achievement'),
                _buildFilterChip('Дуэли', 'duel_complete'),
                _buildFilterChip('Сундуки', 'chest_open'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // History List
          if (logProvider.logs.isEmpty)
            const Center(child: Text("Нет записей"))
          else
            ...logProvider.logs.map((log) => _buildHistoryItem(context, log)).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final logProvider = Provider.of<ActivityLogProvider>(context);
    final isSelected = logProvider.selectedType == type;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _onFilterSelect(type),
        backgroundColor: AppColors.backgroundSecondary,
        selectedColor: AppColors.accentPrimary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.accentPrimary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, ActivityLog log) {
    final icon = _iconForType(log.type);
    final color = _colorForType(log.type);

    return MagicCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          log.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.description, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(log.timestamp, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 12)),
          ],
        ),
        trailing: Text(
          log.reward,
          style: TextStyle(
            color: log.reward.startsWith('+') ? AppColors.success : AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'class_task_complete':
        return Icons.task_alt;
      case 'achievement':
        return Icons.emoji_events;
      case 'duel_complete':
        return Icons.sports_kabaddi;
      case 'chest_open':
        return Icons.shop;
      default:
        return Icons.history;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'class_task_complete':
        return AppColors.accentPrimary;
      case 'achievement':
        return AppColors.warning;
      case 'duel_complete':
        return AppColors.accentSecondary;
      case 'chest_open':
        return AppColors.accentTertiary;
      default:
        return AppColors.border;
    }
  }
}
