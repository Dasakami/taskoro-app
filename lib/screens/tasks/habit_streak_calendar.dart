import 'package:flutter/material.dart';
import 'package:taskoro/theme/app_theme.dart';

class HabitStreakCalendar extends StatelessWidget {
  final List<DateTime> completedDates;
  final int currentStreak;

  const HabitStreakCalendar({
    super.key,
    required this.completedDates,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        // Streak display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.gradientPrimary,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
              const SizedBox(width: 8),
              Text(
                '$currentStreak дней подряд',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Calendar grid
        Column(
          children: [
            // Weekday headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('Пн', style: TextStyle(color: AppColors.textSecondary)),
                Text('Вт', style: TextStyle(color: AppColors.textSecondary)),
                Text('Ср', style: TextStyle(color: AppColors.textSecondary)),
                Text('Чт', style: TextStyle(color: AppColors.textSecondary)),
                Text('Пт', style: TextStyle(color: AppColors.textSecondary)),
                Text('Сб', style: TextStyle(color: AppColors.textSecondary)),
                Text('Вс', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),

            // Calendar days
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 42, // 6 weeks
              itemBuilder: (context, index) {
                final dayOffset = index - (firstWeekday - 1);
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return Container();
                }

                final date = DateTime(now.year, now.month, dayOffset + 1);
                final isCompleted = completedDates.any((d) =>
                d.year == date.year &&
                    d.month == date.month &&
                    d.day == date.day);
                final isToday = date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;

                return Container(
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.accentPrimary
                        : isToday
                        ? AppColors.backgroundSecondary
                        : Colors.transparent,
                    border: Border.all(
                      color: isToday ? AppColors.accentPrimary : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${dayOffset + 1}',
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.white
                            : isToday
                            ? AppColors.accentPrimary
                            : AppColors.textPrimary,
                        fontWeight:
                        isCompleted || isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}