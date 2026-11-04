import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plow_plant_care/utils/responsive.dart';

void main() {
  group('Responsive Breakpoint Tests', () {
    testWidgets('Compact breakpoint at 320px (small phone)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      ScreenType? detectedType;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              detectedType = Responsive.getScreenType(context);
              return Text('Width: ${MediaQuery.of(context).size.width}');
            },
          ),
        ),
      );

      expect(detectedType, equals(ScreenType.compact));
    });

    testWidgets('Compact breakpoint at 390px (standard smartphone)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      ScreenType? detectedType;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              detectedType = Responsive.getScreenType(context);
              return Text('Width: ${MediaQuery.of(context).size.width}');
            },
          ),
        ),
      );

      expect(detectedType, equals(ScreenType.compact));
    });

    testWidgets('Medium breakpoint at 768px (iPad / Tablet)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      ScreenType? detectedType;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              detectedType = Responsive.getScreenType(context);
              return Text('Width: ${MediaQuery.of(context).size.width}');
            },
          ),
        ),
      );

      expect(detectedType, equals(ScreenType.medium));
    });

    testWidgets('Expanded breakpoint at 1440px (Desktop / Laptop)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      ScreenType? detectedType;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              detectedType = Responsive.getScreenType(context);
              return Text('Width: ${MediaQuery.of(context).size.width}');
            },
          ),
        ),
      );

      expect(detectedType, equals(ScreenType.expanded));
    });

    testWidgets('ResponsiveBuilder renders correct layout for compact vs expanded', (WidgetTester tester) async {
      // Test compact
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, screenType) {
              if (screenType == ScreenType.compact) {
                return const Text('COMPACT_LAYOUT');
              } else {
                return const Text('EXPANDED_LAYOUT');
              }
            },
          ),
        ),
      );

      expect(find.text('COMPACT_LAYOUT'), findsOneWidget);
      expect(find.text('EXPANDED_LAYOUT'), findsNothing);

      // Change to expanded
      tester.view.physicalSize = const Size(1440, 900);
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, screenType) {
              if (screenType == ScreenType.compact) {
                return const Text('COMPACT_LAYOUT');
              } else {
                return const Text('EXPANDED_LAYOUT');
              }
            },
          ),
        ),
      );

      expect(find.text('EXPANDED_LAYOUT'), findsOneWidget);
      expect(find.text('COMPACT_LAYOUT'), findsNothing);

      tester.view.resetPhysicalSize();
    });

    testWidgets('Text scale clamping respects 0.9 to 1.2 bounds', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
          child: Builder(
            builder: (context) {
              final clamped = Responsive.clampedTextScale(context);
              expect(clamped, lessThanOrEqualTo(1.2));
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(0.5)),
          child: Builder(
            builder: (context) {
              final clamped = Responsive.clampedTextScale(context);
              expect(clamped, greaterThanOrEqualTo(0.9));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
