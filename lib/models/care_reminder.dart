import 'plant.dart';

class CareReminderTask {
  final String id;
  final String plantId;
  final String plantName;
  final String species;
  final String location;
  final String emojiAvatar;
  final CareType careType;
  final DateTime dueDate;
  bool isCompleted;

  CareReminderTask({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.species,
    required this.location,
    required this.emojiAvatar,
    required this.careType,
    required this.dueDate,
    this.isCompleted = false,
  });

  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return target.difference(today).inDays;
  }

  bool get isOverdue => daysUntilDue < 0 && !isCompleted;
  bool get isDueToday => daysUntilDue == 0 && !isCompleted;
}
