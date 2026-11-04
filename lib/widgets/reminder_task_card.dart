import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/care_reminder.dart';
import '../models/plant.dart';

class ReminderTaskCard extends StatefulWidget {
  final CareReminderTask task;
  final VoidCallback onComplete;

  const ReminderTaskCard({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  State<ReminderTaskCard> createState() => _ReminderTaskCardState();
}

class _ReminderTaskCardState extends State<ReminderTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleComplete() async {
    setState(() => _isChecking = true);
    await _animController.forward();
    await _animController.reverse();
    widget.onComplete();
  }

  Color _getCareTypeColor(CareType type) {
    switch (type) {
      case CareType.water:
        return AppColors.waterBlue;
      case CareType.mist:
        return AppColors.mistCyan;
      case CareType.fertilize:
        return AppColors.fertilizeAmber;
      case CareType.sunlight:
        return AppColors.sunYellow;
      case CareType.repot:
        return AppColors.terracotta;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = widget.task;
    final isOverdue = task.isOverdue;
    final isToday = task.isDueToday;

    String dueLabel;
    Color dueColor;
    if (isOverdue) {
      dueLabel = '${task.daysUntilDue.abs()}d Overdue';
      dueColor = AppColors.urgent;
    } else if (isToday) {
      dueLabel = 'Due Today';
      dueColor = AppColors.warning;
    } else {
      dueLabel = 'In ${task.daysUntilDue} days';
      dueColor = AppColors.primaryLight;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue
                ? AppColors.urgent.withOpacity(0.5)
                : isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
            width: isOverdue ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Plant Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.accentSage.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  task.emojiAvatar,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Plant Details & Care info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          task.plantName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Care Type Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getCareTypeColor(task.careType)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              task.careType.iconEmoji,
                              style: const TextStyle(fontSize: 11),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.careType.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getCareTypeColor(task.careType),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        task.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: dueColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dueLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: dueColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Complete button with animation
            ElevatedButton(
              onPressed: _isChecking ? null : _handleComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isChecking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Done',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
