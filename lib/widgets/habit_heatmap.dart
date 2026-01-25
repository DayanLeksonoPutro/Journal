import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HabitHeatmap extends StatelessWidget {
  final Map<String, bool>
      habitData; // Map of date string (yyyy-MM-dd) -> completed
  final String habitName;
  final Function(String date, bool value)? onDayTap;

  const HabitHeatmap({
    super.key,
    required this.habitData,
    required this.habitName,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    habitName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStreakBadge(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM yyyy').format(now),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCalendarGrid(startOfMonth, endOfMonth),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildLegend(),
        ),
      ],
    );
  }

  Widget _buildStreakBadge() {
    final streak = _calculateStreak();
    if (streak == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            '$streak day${streak > 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStreak() {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final dateKey = DateFormat('yyyy-MM-dd').format(checkDate);
      if (habitData[dateKey] == true) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Widget _buildCalendarGrid(DateTime start, DateTime end) {
    final daysInMonth = end.day;
    final firstWeekday = start.weekday % 7; // 0 = Sunday, 6 = Saturday

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        _buildWeeksGrid(firstWeekday, daysInMonth, start),
      ],
    );
  }

  Widget _buildWeeksGrid(
      int firstWeekday, int daysInMonth, DateTime monthStart) {
    List<Widget> weeks = [];
    int currentDay = 1;

    // Calculate total cells needed
    int totalCells = firstWeekday + daysInMonth;
    int numWeeks = (totalCells / 7).ceil();

    for (int week = 0; week < numWeeks; week++) {
      List<Widget> days = [];

      for (int weekday = 0; weekday < 7; weekday++) {
        if (week == 0 && weekday < firstWeekday) {
          // Empty cell before month starts
          days.add(_buildEmptyDay());
        } else if (currentDay <= daysInMonth) {
          // Day cell
          final date = DateTime(monthStart.year, monthStart.month, currentDay);
          days.add(_buildDayCell(date, currentDay));
          currentDay++;
        } else {
          // Empty cell after month ends
          days.add(_buildEmptyDay());
        }
      }

      weeks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days,
          ),
        ),
      );
    }

    return Column(children: weeks);
  }

  Widget _buildDayCell(DateTime date, int day) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final isCompleted = habitData[dateKey] == true;
    final isToday = _isToday(date);
    final isFuture = date.isAfter(DateTime.now());

    return GestureDetector(
      onTap: isFuture
          ? null
          : () {
              onDayTap?.call(dateKey, !isCompleted);
            },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isFuture
              ? Colors.grey[100]
              : isCompleted
                  ? Colors.green.shade400
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isFuture
                  ? Colors.grey[400]
                  : isCompleted
                      ? Colors.white
                      : Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDay() {
    return const SizedBox(width: 40, height: 40);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.grey[200]!, 'Not Done'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.green.shade400, 'Completed'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.blue, 'Today', isBorder: true),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isBorder = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isBorder ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(4),
            border: isBorder ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
