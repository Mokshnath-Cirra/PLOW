import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/plant_provider.dart';
import '../widgets/plant_card.dart';
import '../widgets/empty_state_view.dart';
import 'plant_detail_screen.dart';
import 'add_edit_plant_screen.dart';

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantProvider = context.watch<PlantProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plants = plantProvider.filteredPlants;
    final locations = plantProvider.availableLocations;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Plant Collection',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Plant',
            icon: const Icon(Icons.add_circle_outline_rounded, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditPlantScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => plantProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search by plant name, species, or room...',
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          plantProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Location Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: locations.map((loc) {
                final isSelected = plantProvider.selectedLocation == loc;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(loc),
                    selected: isSelected,
                    onSelected: (_) => plantProvider.setSelectedLocation(loc),
                    backgroundColor:
                        isDark ? AppColors.darkCard : AppColors.lightCard,
                    selectedColor: isDark
                        ? AppColors.primaryGreen.withOpacity(0.5)
                        : AppColors.accentSage,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? (isDark
                              ? AppColors.accentMint
                              : AppColors.primaryDark)
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Grid View of Plants
          Expanded(
            child: plants.isEmpty
                ? EmptyStateView(
                    emoji: '🔍',
                    title: 'No Plants Found',
                    message:
                        'Try clearing your search query or add a brand new plant to your collection.',
                    buttonText: 'Add New Plant',
                    onButtonPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEditPlantScreen(),
                        ),
                      );
                    },
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive Columns based on screen width
                      int crossAxisCount = 1;
                      double childAspectRatio = 1.1;

                      if (constraints.maxWidth > 1100) {
                        crossAxisCount = 3;
                        childAspectRatio = 1.15;
                      } else if (constraints.maxWidth > 700) {
                        crossAxisCount = 2;
                        childAspectRatio = 1.15;
                      } else {
                        crossAxisCount = 1;
                        childAspectRatio = 1.45;
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: plants.length,
                        itemBuilder: (context, index) {
                          final plant = plants[index];
                          return PlantCard(
                            plant: plant,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlantDetailScreen(plantId: plant.id),
                                ),
                              );
                            },
                            onQuickWater: () {
                              plantProvider.waterPlant(plant.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '💧 ${plant.name} watered thoroughly!'),
                                  backgroundColor: AppColors.primaryGreen,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
