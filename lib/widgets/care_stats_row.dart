import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CareStatsRow extends StatelessWidget {
  final int totalPlants;
  final int urgentTasks;
  final int careStreak;
  final double averageHealth;

  const CareStatsRow({
    super.key,
    required this.totalPlants,
    required this.urgentTasks,
    required this.careStreak,
    required this.averageHealth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 650;

        final items = [
          _buildStatCard(
            context,
            icon: Icons.local_florist_rounded,
            iconColor: AppColors.primaryGreen,
            value: totalPlants.toString(),
            label: 'Total Plants',
            highlightColor: AppColors.accentSage,
          ),
          _buildStatCard(
            context,
            icon: Icons.alarm_on_rounded,
            iconColor: urgentTasks > 0 ? AppColors.urgent : AppColors.success,
            value: urgentTasks.toString(),
            label: 'Due Today',
            highlightColor: urgentTasks > 0
                ? AppColors.urgent.withOpacity(0.12)
                : AppColors.success.withOpacity(0.12),
          ),
          _buildStatCard(
            context,
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.terracotta,
            value: '$careStreak Days',
            label: 'Care Streak',
            highlightColor: AppColors.terracotta.withOpacity(0.12),
          ),
          _buildStatCard(
            context,
            icon: Icons.favorite_rounded,
            iconColor: AppColors.primaryLight,
            value: '${averageHealth.toInt()}%',
            label: 'Garden Health',
            highlightColor: AppColors.primaryLight.withOpacity(0.12),
          ),
        ];

        if (isSmallScreen) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: items,
          );
        }

        return Row(
          children: items
              .map((card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: card,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color highlightColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: highlightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
