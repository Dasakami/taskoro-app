import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/activity_log_provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:taskoro/widgets/magic_card.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:intl/intl.dart';

import '../models/activity_log_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityLogProvider>(context, listen: false).fetchLogs();
    });
  }

  void _onFilterSelect(String? type) {
    setState(() {
      _selectedFilter = type;
    });
  }

  List<ActivityLog> _getFilteredLogs(List<ActivityLog> logs) {
    if (_selectedFilter == null || _selectedFilter!.isEmpty) {
      return logs;
    }
    return logs.where((log) => log.type == _selectedFilter).toList();
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Только что';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} мин назад';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ч назад';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} дн назад';
      } else {
        return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<ActivityLogProvider>(context);
    final filteredLogs = _getFilteredLogs(logProvider.logs);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'История',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ваша активность и достижения',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('Все', null),
                  _buildFilterChip('Задачи', 'class_task_complete'),
                  _buildFilterChip('Достижения', 'achievement'),
                  _buildFilterChip('Дуэли', 'duel_complete'),
                  _buildFilterChip('Сундуки', 'chest_open'),
                  _buildFilterChip('Уровень', 'level_up'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accentPrimary,
                onRefresh: () async {
                  await logProvider.fetchLogs();
                },
                child: logProvider.isLoading && logProvider.logs.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentPrimary,
                        ),
                      )
                    : logProvider.error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Ошибка загрузки',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    logProvider.error!,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => logProvider.fetchLogs(),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Повторить'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentPrimary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : filteredLogs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 64,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _selectedFilter == null
                                          ? 'Нет записей'
                                          : 'Нет записей по фильтру',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (_selectedFilter != null) ...[
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () => _onFilterSelect(null),
                                        child: const Text('Показать все'),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: filteredLogs.length,
                                itemBuilder: (context, index) {
                                  final log = filteredLogs[index];
                                  return _buildHistoryItem(context, log);
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? type) {
    final isSelected = _selectedFilter == type;

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
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.accentPrimary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, ActivityLog log) {
    final icon = _iconForType(log.type);
    final color = _colorForType(log.type);
    final isPositiveReward = log.reward.startsWith('+');

    return MagicCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showLogDetails(context, log),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      log.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    if (log.description.isNotEmpty)
                      Text(
                        log.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),

                    // Time and reward row
                    Row(
                      children: [
                        // Time
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(log.timestamp),
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),

                        // Reward
                        if (log.reward != '-')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPositiveReward
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isPositiveReward
                                    ? AppColors.success.withOpacity(0.3)
                                    : AppColors.error.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              log.reward,
                              style: TextStyle(
                                color: isPositiveReward
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogDetails(BuildContext context, ActivityLog log) {
    final icon = _iconForType(log.type);
    final color = _colorForType(log.type);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(log.timestamp),
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            if (log.description.isNotEmpty) ...[
              const Text(
                'Описание',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                log.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Reward
            if (log.reward != '-') ...[
              const Text(
                'Награда',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log.reward,
                  style: TextStyle(
                    color: log.reward.startsWith('+')
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'class_task_complete':
      case 'task_complete':
        return Icons.task_alt;
      case 'achievement':
        return Icons.emoji_events;
      case 'duel_complete':
        return Icons.sports_kabaddi;
      case 'chest_open':
        return Icons.card_giftcard;
      case 'level_up':
        return Icons.trending_up;
      case 'tournament_join':
        return Icons.event;
      case 'tournament_win':
        return Icons.military_tech;
      default:
        return Icons.history;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'class_task_complete':
      case 'task_complete':
        return AppColors.accentPrimary;
      case 'achievement':
        return AppColors.warning;
      case 'duel_complete':
        return AppColors.accentSecondary;
      case 'chest_open':
        return AppColors.accentTertiary;
      case 'level_up':
        return AppColors.success;
      case 'tournament_join':
      case 'tournament_win':
        return Colors.purple;
      default:
        return AppColors.border;
    }
  }
}