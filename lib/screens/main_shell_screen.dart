import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive.dart';
import 'dashboard_screen.dart';
import 'scanner_screen.dart';
import 'my_plants_screen.dart';
import 'plant_library_screen.dart';
import 'plant_guide_screen.dart';

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
    PlantLibraryScreen(),
    PlantGuideScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(Responsive.clampedTextScale(context)),
      ),
      child: ResponsiveBuilder(
        builder: (context, screenType) {
          if (screenType == ScreenType.expanded) {
            // DESKTOP LAYOUT (> 1024px)
            return Scaffold(
              body: Row(
                children: [
                  // Left Navigation Sidebar
                  Container(
                    width: 260,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      border: Border(
                        right: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // App Brand
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text('🌿', style: TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FloraScan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                                    ),
                                  ),
                                  const Text(
                                    'AI Plant Care & Pathology',
                                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Nav Items
                        _buildDesktopNavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard', 0, isDark),
                        _buildDesktopNavItem(Icons.camera_alt_outlined, Icons.camera_alt_rounded, 'AI Scanner', 1, isDark),
                        _buildDesktopNavItem(Icons.yard_outlined, Icons.yard_rounded, 'My Garden', 2, isDark),
                        _buildDesktopNavItem(Icons.local_florist_outlined, Icons.local_florist_rounded, 'Plant Library', 3, isDark),
                        _buildDesktopNavItem(Icons.menu_book_outlined, Icons.menu_book_rounded, 'Care Guide', 4, isDark),

                        const Spacer(),

                        // Theme & User Settings Footer
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isDark ? 'Dark Mode' : 'Light Mode',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: isDark,
                                onChanged: (_) => themeProvider.toggleTheme(),
                                activeColor: AppColors.primaryLight,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content View (max 1200px centered)
                  Expanded(
                    child: SafeArea(
                      child: ResponsiveContainer(
                        child: _screens[_currentIndex],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // MOBILE (<600px) & TABLET (600-1024px) FULL SCREEN LAYOUT
          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 74), // Room for bottom nav bar
                child: _screens[_currentIndex],
              ),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.camera_alt_outlined),
                  selectedIcon: Icon(Icons.camera_alt_rounded),
                  label: 'Scan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.yard_outlined),
                  selectedIcon: Icon(Icons.yard_rounded),
                  label: 'Garden',
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_florist_outlined),
                  selectedIcon: Icon(Icons.local_florist_rounded),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Guide',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
    bool isDark,
  ) {
    final isSelected = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.darkCard : AppColors.accentSage.withOpacity(0.5))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.primaryLight.withOpacity(0.5))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected ? AppColors.primaryGreen : Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? (isDark ? Colors.white : AppColors.primaryDark) : Colors.grey,
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
