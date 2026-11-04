import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../providers/plant_provider.dart';
import '../providers/theme_provider.dart';
import '../models/plant.dart';
import '../widgets/care_stats_row.dart';
import '../widgets/reminder_task_card.dart';
import '../utils/responsive.dart';
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
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
              ),
            ),
            Text(
              todayFormatted,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
      body: ResponsiveContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Summary Row
              CareStatsRow(
                totalPlants: plantProvider.totalPlants,
                urgentTasks: plantProvider.urgentWaterCount,
                careStreak: plantProvider.careStreakDays,
                averageHealth: plantProvider.averageGardenHealth,
              ),
              const SizedBox(height: 20),

              // Responsive Two-Column or Single-Column Dashboard Body
              ResponsiveBuilder(
                builder: (context, screenType) {
                  final isDesktop = screenType == ScreenType.expanded;

                  final leftColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All Tasks', _selectedFilterType == null, () => setState(() => _selectedFilterType = null)),
                            const SizedBox(width: 8),
                            _buildFilterChip('💧 Watering', _selectedFilterType == CareType.water, () => setState(() => _selectedFilterType = CareType.water)),
                            const SizedBox(width: 8),
                            _buildFilterChip('🧴 Misting', _selectedFilterType == CareType.mist, () => setState(() => _selectedFilterType = CareType.mist)),
                            const SizedBox(width: 8),
                            _buildFilterChip('🧪 Fertilizing', _selectedFilterType == CareType.fertilize, () => setState(() => _selectedFilterType = CareType.fertilize)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Section Header: Needs Care Today
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Needs Care Today',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: urgentAndToday.isNotEmpty ? AppColors.urgent.withOpacity(0.15) : AppColors.success.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${urgentAndToday.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: urgentAndToday.isNotEmpty ? AppColors.urgent : AppColors.success,
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
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (urgentAndToday.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: const Column(
                            children: [
                              Text('🌿', style: TextStyle(fontSize: 36)),
                              SizedBox(height: 8),
                              Text('All caught up for today!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Your plants are well-hydrated and thriving.', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                              },
                            );
                          },
                        ),
                    ],
                  );

                  final rightColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Upcoming in Next 3 Days
                      Text(
                        'Upcoming in Next 3 Days',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (upcoming.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: const Text('No upcoming tasks scheduled in the next 3 days.', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                      const SizedBox(height: 20),

                      // Quick Action: Add custom plant
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddEditPlantScreen()),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Custom Plant to Garden'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  );

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: leftColumn),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: rightColumn),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      leftColumn,
                      const SizedBox(height: 24),
                      rightColumn,
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.primaryDark : Colors.grey,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
