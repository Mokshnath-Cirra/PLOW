import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../providers/plant_provider.dart';
import '../providers/theme_provider.dart';
import '../models/plant.dart';
import '../widgets/care_stats_row.dart';
import '../widgets/reminder_task_card.dart';
import '../widgets/empty_state_view.dart';
import 'add_edit_plant_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CareType? _selectedFilterType;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final plantProvider = context.watch<PlantProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final urgentAndToday = plantProvider.urgentAndTodayTasks.where((task) {
      if (_selectedFilterType == null) return true;
      return task.careType == _selectedFilterType;
    }).toList();

    final upcoming = plantProvider.upcomingTasks.where((task) {
      if (_selectedFilterType == null) return true;
      return task.careType == _selectedFilterType;
    }).toList();

    final todayFormatted = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
              ),
            ),
            Text(
              todayFormatted,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppColors.sunYellow : AppColors.primaryDark,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            CareStatsRow(
              totalPlants: plantProvider.totalPlants,
              urgentTasks: plantProvider.urgentWaterCount,
              careStreak: plantProvider.careStreakDays,
              averageHealth: plantProvider.averageGardenHealth,
            ),
            const SizedBox(height: 24),

            // Filter Chips for Care Tasks
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All Tasks',
                    isSelected: _selectedFilterType == null,
                    onSelected: () => setState(() => _selectedFilterType = null),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '💧 Watering',
                    isSelected: _selectedFilterType == CareType.water,
                    onSelected: () =>
                        setState(() => _selectedFilterType = CareType.water),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '🧴 Misting',
                    isSelected: _selectedFilterType == CareType.mist,
                    onSelected: () =>
                        setState(() => _selectedFilterType = CareType.mist),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '🧪 Fertilizing',
                    isSelected: _selectedFilterType == CareType.fertilize,
                    onSelected: () => setState(
                        () => _selectedFilterType = CareType.fertilize),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Due Today / Overdue Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Needs Care Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: urgentAndToday.isNotEmpty
                            ? AppColors.urgent.withOpacity(0.15)
                            : AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${urgentAndToday.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: urgentAndToday.isNotEmpty
                              ? AppColors.urgent
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                if (urgentAndToday.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      for (var task in urgentAndToday) {
                        plantProvider.performCare(task.plantId, task.careType);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 All due tasks marked as completed!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('Complete All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Urgent Task List or Empty State
            if (urgentAndToday.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    const Text('🌿', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 10),
                    Text(
                      'All caught up for today!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your plants are well-hydrated and thriving. Great job!',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: urgentAndToday.length,
                itemBuilder: (context, index) {
                  final task = urgentAndToday[index];
                  return ReminderTaskCard(
                    task: task,
                    onComplete: () {
                      plantProvider.performCare(task.plantId, task.careType);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '✅ Logged ${task.careType.displayName} for ${task.plantName}!'),
                          backgroundColor: AppColors.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),

            const SizedBox(height: 32),

            // Upcoming Schedule Section
            Text(
              'Upcoming in Next 3 Days',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (upcoming.isEmpty)
              Text(
                'No upcoming tasks scheduled in the next 3 days.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcoming.length,
                itemBuilder: (context, index) {
                  final task = upcoming[index];
                  return ReminderTaskCard(
                    task: task,
                    onComplete: () {
                      plantProvider.performCare(task.plantId, task.careType);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightCard,
      selectedColor: isDark
          ? AppColors.primaryGreen.withOpacity(0.5)
          : AppColors.accentSage,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? (isDark ? AppColors.accentMint : AppColors.primaryDark)
            : (isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? AppColors.primaryGreen
              : isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
        ),
      ),
    );
  }
}
