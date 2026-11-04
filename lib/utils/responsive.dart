import 'package:flutter/material.dart';

enum ScreenType {
  compact, // < 600px (Mobile Phones)
  medium,  // 600 - 1024px (Tablets / Small screens)
  expanded // > 1024px (Desktops / Laptops)
}

class Responsive {
  static const double compactBreakpoint = 600.0;
  static const double mediumBreakpoint = 1024.0;
  static const double maxContentWidth = 1200.0;
  static const double minTouchTarget = 48.0;

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < compactBreakpoint) {
      return ScreenType.compact;
    } else if (width <= mediumBreakpoint) {
      return ScreenType.medium;
    } else {
      return ScreenType.expanded;
    }
  }

  static bool isCompact(BuildContext context) =>
      getScreenType(context) == ScreenType.compact;

  static bool isMedium(BuildContext context) =>
      getScreenType(context) == ScreenType.medium;

  static bool isExpanded(BuildContext context) =>
      getScreenType(context) == ScreenType.expanded;

  static double clampedTextScale(BuildContext context) {
    final scale = MediaQuery.of(context).textScaler.scale(1.0);
    return scale.clamp(0.9, 1.2);
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        ScreenType screenType;
        if (constraints.maxWidth < Responsive.compactBreakpoint) {
          screenType = ScreenType.compact;
        } else if (constraints.maxWidth <= Responsive.mediumBreakpoint) {
          screenType = ScreenType.medium;
        } else {
          screenType = ScreenType.expanded;
        }
        return builder(context, screenType);
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
