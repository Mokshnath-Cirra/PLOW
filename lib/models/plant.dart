enum CareType {
  water,
  mist,
  fertilize,
  repot,
  sunlight,
}

extension CareTypeExtension on CareType {
  String get displayName {
    switch (this) {
      case CareType.water:
        return 'Watering';
      case CareType.mist:
        return 'Misting';
      case CareType.fertilize:
        return 'Fertilizing';
      case CareType.repot:
        return 'Repotting';
      case CareType.sunlight:
        return 'Sunlight Rotation';
    }
  }

  String get iconEmoji {
    switch (this) {
      case CareType.water:
        return '💧';
      case CareType.mist:
        return '🧴';
      case CareType.fertilize:
        return '🧪';
      case CareType.repot:
        return '🪴';
      case CareType.sunlight:
        return '☀️';
    }
  }
}

enum SunlightLevel {
  lowLight,
  indirectBright,
  directSunlight,
}

extension SunlightLevelExtension on SunlightLevel {
  String get displayName {
    switch (this) {
      case SunlightLevel.lowLight:
        return 'Low / Shade';
      case SunlightLevel.indirectBright:
        return 'Bright Indirect';
      case SunlightLevel.directSunlight:
        return 'Direct Sun';
    }
  }
}

class CareLog {
  final String id;
  final CareType type;
  final DateTime timestamp;
  final String? note;

  CareLog({
    required this.id,
    required this.type,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory CareLog.fromJson(Map<String, dynamic> json) => CareLog(
        id: json['id'] as String,
        type: CareType.values.byName(json['type'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        note: json['note'] as String?,
      );
}

class Plant {
  final String id;
  String name;
  String species;
  String location; // e.g. "Living Room", "Balcony", "Office"
  String category; // e.g. "Indoor", "Succulent", "Fern", "Tropical"
  int waterIntervalDays;
  int mistIntervalDays;
  int fertilizeIntervalDays;
  SunlightLevel sunlight;
  DateTime lastWatered;
  DateTime? lastMisted;
  DateTime? lastFertilized;
  String notes;
  int healthScore; // 0 to 100
  String emojiAvatar;
  List<CareLog> logs;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.location,
    required this.category,
    this.waterIntervalDays = 7,
    this.mistIntervalDays = 3,
    this.fertilizeIntervalDays = 30,
    this.sunlight = SunlightLevel.indirectBright,
    required this.lastWatered,
    this.lastMisted,
    this.lastFertilized,
    this.notes = '',
    this.healthScore = 90,
    this.emojiAvatar = '🌿',
    List<CareLog>? logs,
  }) : logs = logs ?? [];

  DateTime get nextWaterDate =>
      lastWatered.add(Duration(days: waterIntervalDays));

  int get daysUntilWater {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(nextWaterDate.year, nextWaterDate.month, nextWaterDate.day);
    return target.difference(today).inDays;
  }

  bool get isWaterDue => daysUntilWater <= 0;

  double get hydrationPercentage {
    final now = DateTime.now();
    final elapsedDays = now.difference(lastWatered).inDays;
    if (waterIntervalDays <= 0) return 0.0;
    final remaining = (waterIntervalDays - elapsedDays) / waterIntervalDays;
    return remaining.clamp(0.0, 1.0);
  }

  void water({String? note}) {
    lastWatered = DateTime.now();
    logs.insert(
      0,
      CareLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: CareType.water,
        timestamp: DateTime.now(),
        note: note ?? 'Watered thoroughly',
      ),
    );
    healthScore = (healthScore + 5).clamp(0, 100);
  }

  void mist({String? note}) {
    lastMisted = DateTime.now();
    logs.insert(
      0,
      CareLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: CareType.mist,
        timestamp: DateTime.now(),
        note: note ?? 'Misted foliage',
      ),
    );
    healthScore = (healthScore + 2).clamp(0, 100);
  }

  void fertilize({String? note}) {
    lastFertilized = DateTime.now();
    logs.insert(
      0,
      CareLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: CareType.fertilize,
        timestamp: DateTime.now(),
        note: note ?? 'Applied balanced fertilizer',
      ),
    );
    healthScore = (healthScore + 5).clamp(0, 100);
  }

  Plant copyWith({
    String? id,
    String? name,
    String? species,
    String? location,
    String? category,
    int? waterIntervalDays,
    int? mistIntervalDays,
    int? fertilizeIntervalDays,
    SunlightLevel? sunlight,
    DateTime? lastWatered,
    DateTime? lastMisted,
    DateTime? lastFertilized,
    String? notes,
    int? healthScore,
    String? emojiAvatar,
    List<CareLog>? logs,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      location: location ?? this.location,
      category: category ?? this.category,
      waterIntervalDays: waterIntervalDays ?? this.waterIntervalDays,
      mistIntervalDays: mistIntervalDays ?? this.mistIntervalDays,
      fertilizeIntervalDays:
          fertilizeIntervalDays ?? this.fertilizeIntervalDays,
      sunlight: sunlight ?? this.sunlight,
      lastWatered: lastWatered ?? this.lastWatered,
      lastMisted: lastMisted ?? this.lastMisted,
      lastFertilized: lastFertilized ?? this.lastFertilized,
      notes: notes ?? this.notes,
      healthScore: healthScore ?? this.healthScore,
      emojiAvatar: emojiAvatar ?? this.emojiAvatar,
      logs: logs ?? List.from(this.logs),
    );
  }
}
