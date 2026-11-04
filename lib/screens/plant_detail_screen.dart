import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';
import '../widgets/animated_water_bar.dart';
import 'add_edit_plant_screen.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    final plantProvider = context.watch<PlantProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plant = plantProvider.getPlantById(plantId);

    if (plant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Plant not found.')),
      );
    }

    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          plant.name,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Plant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditPlantScreen(plantToEdit: plant),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.urgent),
            tooltip: 'Delete Plant',
            onPressed: () => _confirmDelete(context, plantProvider, plant),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Card with Hero Avatar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'plant_avatar_${plant.id}',
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.accentSage.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              plant.emojiAvatar,
                              style: const TextStyle(fontSize: 44),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              plant.species,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                Chip(
                                  label: Text(plant.location),
                                  avatar: const Icon(Icons.room, size: 14),
                                  backgroundColor: isDark
                                      ? AppColors.darkSurface
                                      : AppColors.lightBg,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Chip(
                                  label: Text(plant.category),
                                  avatar: const Icon(Icons.eco_rounded,
                                      size: 14, color: AppColors.primaryLight),
                                  backgroundColor: isDark
                                      ? AppColors.darkSurface
                                      : AppColors.lightBg,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Hydration and Health Indicator
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Soil Hydration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: plant.daysUntilWater <= 0
                                  ? AppColors.urgent.withOpacity(0.12)
                                  : AppColors.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              plant.daysUntilWater <= 0
                                  ? 'Needs Water Now'
                                  : 'Due in ${plant.daysUntilWater} days',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: plant.daysUntilWater <= 0
                                    ? AppColors.urgent
                                    : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnimatedWaterBar(
                        percentage: plant.hydrationPercentage,
                        height: 12,
                        showLabel: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Care Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          plantProvider.waterPlant(plant.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('💧 Watered successfully!'),
                              backgroundColor: AppColors.waterBlue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.water_drop_rounded, size: 18),
                        label: const Text('Water'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.waterBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          plantProvider.mistPlant(plant.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🧴 Foliage misted!'),
                              backgroundColor: AppColors.mistCyan,
                            ),
                          );
                        },
                        icon: const Icon(Icons.cloud_rounded, size: 18),
                        label: const Text('Mist'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mistCyan,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          plantProvider.fertilizePlant(plant.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🧪 Fertilized!'),
                              backgroundColor: AppColors.fertilizeAmber,
                            ),
                          );
                        },
                        icon: const Icon(Icons.science_rounded, size: 18),
                        label: const Text('Fertilize'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.fertilizeAmber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Care Schedule & Requirements Grid
                Text(
                  'Care Schedule & Requirements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.3,
                  children: [
                    _buildInfoCard(
                      icon: Icons.water_drop,
                      color: AppColors.waterBlue,
                      title: 'Watering Interval',
                      subtitle: 'Every ${plant.waterIntervalDays} days',
                      isDark: isDark,
                    ),
                    _buildInfoCard(
                      icon: Icons.wb_sunny_rounded,
                      color: AppColors.sunYellow,
                      title: 'Light Level',
                      subtitle: plant.sunlight.displayName,
                      isDark: isDark,
                    ),
                    _buildInfoCard(
                      icon: Icons.waves_rounded,
                      color: AppColors.mistCyan,
                      title: 'Misting Schedule',
                      subtitle: 'Every ${plant.mistIntervalDays} days',
                      isDark: isDark,
                    ),
                    _buildInfoCard(
                      icon: Icons.eco_rounded,
                      color: AppColors.fertilizeAmber,
                      title: 'Fertilizing Schedule',
                      subtitle: 'Every ${plant.fertilizeIntervalDays} days',
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Notes Section
                if (plant.notes.isNotEmpty) ...[
                  Text(
                    'Plant Care Notes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Text(
                      plant.notes,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Care History Timeline
                Text(
                  'Recent Care History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (plant.logs.isEmpty)
                  Text(
                    'No care activity logged yet.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: plant.logs.length,
                    itemBuilder: (context, index) {
                      final log = plant.logs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(log.type.iconEmoji,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.note ?? log.type.displayName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${dateFormat.format(log.timestamp)} at ${timeFormat.format(log.timestamp)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
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

  void _confirmDelete(
      BuildContext context, PlantProvider provider, Plant plant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Plant?'),
        content: Text(
            'Are you sure you want to remove "${plant.name}" from your collection? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deletePlant(plant.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Return to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed ${plant.name} from your garden.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.urgent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
