import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:plow_plant_care/providers/plant_provider.dart';
import 'package:plow_plant_care/providers/theme_provider.dart';
import 'package:plow_plant_care/screens/main_shell_screen.dart';

void main() {
  testWidgets('MainShell renders app title and navigation items',
      (WidgetTester tester) async {
    // Build our widget tree with providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => PlantProvider()),
        ],
        child: const MaterialApp(
          home: MainShellScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify key UI text elements exist
    expect(find.text('Care Dashboard'), findsWidgets);
    expect(find.text('My Garden'), findsWidgets);
    expect(find.text('Care Guide'), findsWidgets);
  });
}
