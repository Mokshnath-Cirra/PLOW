import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';
import 'dashboard_screen.dart';
import 'scanner_screen.dart';
import 'my_plants_screen.dart';
import 'plant_guide_screen.dart';
import 'add_edit_plant_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ScannerScreen(),
    MyPlantsScreen(),
    PlantGuideScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        if (isDesktop) {
          // Desktop / Wide Screen: Side Navigation Rail + Main View
          return Scaffold(
            body: Row(
              children: [
                // Navigation Rail Sidebar
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // App Header / Logo
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 28, horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentSage,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('🌱',
                                  style: TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PLOW',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: isDark
                                        ? AppColors.accentMint
                                        : AppColors.primaryDark,
                                  ),
                                ),
                                Text(
                                  'Plant Care Companion',
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
                          ],
                        ),
                      ),

                      // Add Plant Quick Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddEditPlantScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('Add New Plant'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nav Items
                      _buildSidebarNavItem(
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard_rounded,
                        title: 'Care Dashboard',
                        index: 0,
                        isDark: isDark,
                      ),
                      _buildSidebarNavItem(
                        icon: Icons.camera_alt_outlined,
                        activeIcon: Icons.camera_alt_rounded,
                        title: 'AI Scanner',
                        index: 1,
                        isDark: isDark,
                      ),
                      _buildSidebarNavItem(
                        icon: Icons.yard_outlined,
                        activeIcon: Icons.yard_rounded,
                        title: 'My Garden',
                        index: 2,
                        isDark: isDark,
                      ),
                      _buildSidebarNavItem(
                        icon: Icons.menu_book_outlined,
                        activeIcon: Icons.menu_book_rounded,
                        title: 'Care Guide',
                        index: 3,
                        isDark: isDark,
                      ),

                      const Spacer(),

                      // Dark Mode Switch & Version
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.lightBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isDark
                                        ? Icons.dark_mode_rounded
                                        : Icons.light_mode_rounded,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.sunYellow
                                        : AppColors.terracotta,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isDark ? 'Dark Mode' : 'Light Mode',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: isDark,
                                activeColor: AppColors.accentMint,
                                onChanged: (_) => themeProvider.toggleTheme(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Screen Content Area
                Expanded(
                  child: _screens[_currentIndex],
                ),
              ],
            ),
          );
        }

        // Mobile / Narrow Layout: Standard Scaffold with Bottom Navigation Bar
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.camera_alt_outlined),
                selectedIcon: Icon(Icons.camera_alt_rounded),
                label: 'Scan AI',
              ),
              NavigationDestination(
                icon: Icon(Icons.yard_outlined),
                selectedIcon: Icon(Icons.yard_rounded),
                label: 'My Plants',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Care Guide',
              ),
            ],
          ),
          floatingActionButton: _currentIndex != 2
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditPlantScreen(),
                      ),
                    );
                  },
                  tooltip: 'Add Plant',
                  child: const Icon(Icons.add_rounded, size: 28),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? AppColors.darkCard
                      : AppColors.accentSage.withOpacity(0.5))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: isDark
                          ? AppColors.primaryLight.withOpacity(0.4)
                          : AppColors.primaryGreen.withOpacity(0.3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected
                      ? (isDark
                          ? AppColors.accentMint
                          : AppColors.primaryGreen)
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.primaryDark)
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
