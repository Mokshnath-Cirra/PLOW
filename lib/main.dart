import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/plant_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_shell_screen.dart';
import 'screens/add_edit_plant_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/diagnosis_report_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<PlantProvider>(
          create: (_) => PlantProvider(),
        ),
      ],
      child: const PlowApp(),
    ),
  );
}

class PlowApp extends StatelessWidget {
  const PlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'FloraScan • PLOW Plant Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      // Implement Named Routes as taught in Lab Session 4
      initialRoute: '/',
      routes: {
        '/': (context) => const MainShellScreen(),
        '/add-plant': (context) => const AddEditPlantScreen(),
        '/scan': (context) => const ScannerScreen(),
        '/diagnosis': (context) => const DiagnosisReportScreen(),
      },
    );
  }
}
