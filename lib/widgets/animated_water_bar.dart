import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AnimatedWaterBar extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final double height;
  final bool showLabel;

  const AnimatedWaterBar({
    super.key,
    required this.percentage,
    this.height = 8.0,
    this.showLabel = true,
  });

  Color _getStatusColor(double value) {
    if (value > 0.6) return AppColors.primaryLight;
    if (value > 0.25) return AppColors.warning;
    return AppColors.urgent;
  }

  @override
  Widget build(BuildContext context) {
    final clampedValue = percentage.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.water_drop_rounded,
                    size: 14,
                    color: _getStatusColor(clampedValue),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hydration',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '${(clampedValue * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _getStatusColor(clampedValue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: clampedValue),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, child) {
                      return Container(
                        width: constraints.maxWidth * animatedValue,
                        height: height,
                        decoration: BoxDecoration(
                          color: _getStatusColor(animatedValue),
                          borderRadius: BorderRadius.circular(height / 2),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(animatedValue)
                                  .withOpacity(0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
