import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/plant.dart';
import 'animated_water_bar.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;
  final VoidCallback onQuickWater;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    required this.onQuickWater,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = plant.daysUntilWater < 0;
    final isDueToday = plant.daysUntilWater == 0;

    String statusText;
    Color statusColor;
    if (isOverdue) {
      statusText = 'Needs water!';
      statusColor = AppColors.urgent;
    } else if (isDueToday) {
      statusText = 'Water today';
      statusColor = AppColors.warning;
    } else {
      statusText = 'in ${plant.daysUntilWater}d';
      statusColor = AppColors.primaryLight;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar & Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'plant_avatar_${plant.id}',
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.accentSage.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          plant.emojiAvatar,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 13,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Plant Name and Species
              Text(
                plant.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                plant.species,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // Location and Category chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _buildTag(
                    context,
                    Icons.room,
                    plant.location,
                    isDark,
                  ),
                  _buildTag(
                    context,
                    Icons.category_outlined,
                    plant.category,
                    isDark,
                  ),
                ],
              ),

              const Spacer(),
              const SizedBox(height: 10),

              // Hydration progress bar
              AnimatedWaterBar(
                percentage: plant.hydrationPercentage,
                height: 6,
                showLabel: true,
              ),
              const SizedBox(height: 12),

              // Quick action button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onQuickWater,
                  icon: const Icon(Icons.water_drop_outlined, size: 16),
                  label: const Text('Water Now'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.waterBlue,
                    side: const BorderSide(color: AppColors.waterBlue),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(
      BuildContext context, IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
