import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../models/care_reminder.dart';

class PlantProvider with ChangeNotifier {
  final List<Plant> _plants = [];
  String _searchQuery = '';
  String _selectedLocation = 'All';
  String _selectedCategory = 'All';
  int _careStreakDays = 14;
  int _completedTodayCount = 2;

  PlantProvider() {
    _initSamplePlants();
  }

  void _initSamplePlants() {
    final now = DateTime.now();
    _plants.addAll([
      Plant(
        id: 'plant_1',
        name: 'Monty',
        species: 'Monstera Deliciosa',
        location: 'Living Room',
        category: 'Tropical',
        waterIntervalDays: 7,
        mistIntervalDays: 3,
        fertilizeIntervalDays: 30,
        sunlight: SunlightLevel.indirectBright,
        lastWatered: now.subtract(const Duration(days: 7)), // Due today!
        lastMisted: now.subtract(const Duration(days: 1)),
        lastFertilized: now.subtract(const Duration(days: 15)),
        notes: 'Enjoys morning light by the east window. Check moss pole moisture.',
        healthScore: 95,
        emojiAvatar: '🪴',
        logs: [
          CareLog(
            id: 'log_1',
            type: CareType.water,
            timestamp: now.subtract(const Duration(days: 7)),
            note: 'Drenched until water drained from bottom',
          ),
          CareLog(
            id: 'log_2',
            type: CareType.mist,
            timestamp: now.subtract(const Duration(days: 1)),
            note: 'Morning foliage misting',
          ),
        ],
      ),
      Plant(
        id: 'plant_2',
        name: 'Viper',
        species: 'Snake Plant (Sansevieria)',
        location: 'Bedroom',
        category: 'Succulent',
        waterIntervalDays: 14,
        mistIntervalDays: 14,
        fertilizeIntervalDays: 60,
        sunlight: SunlightLevel.lowLight,
        lastWatered: now.subtract(const Duration(days: 16)), // Overdue!
        lastMisted: null,
        lastFertilized: now.subtract(const Duration(days: 45)),
        notes: 'Low light tolerant. Never allow saucer to hold stagnant water.',
        healthScore: 88,
        emojiAvatar: '🌿',
        logs: [
          CareLog(
            id: 'log_3',
            type: CareType.water,
            timestamp: now.subtract(const Duration(days: 16)),
            note: 'Cup of filtered water',
          ),
        ],
      ),
      Plant(
        id: 'plant_3',
        name: 'Lily',
        species: 'Peace Lily',
        location: 'Office',
        category: 'Flowering',
        waterIntervalDays: 5,
        mistIntervalDays: 2,
        fertilizeIntervalDays: 28,
        sunlight: SunlightLevel.indirectBright,
        lastWatered: now.subtract(const Duration(days: 2)), // Due in 3 days
        lastMisted: now.subtract(const Duration(days: 1)),
        notes: 'Very communicative. Wilts dramatically when parched.',
        healthScore: 92,
        emojiAvatar: '🪷',
        logs: [
          CareLog(
            id: 'log_4',
            type: CareType.water,
            timestamp: now.subtract(const Duration(days: 2)),
            note: 'Watered after noticed slight leaf droop',
          ),
        ],
      ),
      Plant(
        id: 'plant_4',
        name: 'Figgy',
        species: 'Fiddle Leaf Fig',
        location: 'Living Room',
        category: 'Tree',
        waterIntervalDays: 8,
        mistIntervalDays: 4,
        fertilizeIntervalDays: 30,
        sunlight: SunlightLevel.indirectBright,
        lastWatered: now.subtract(const Duration(days: 8)), // Due today!
        lastMisted: now.subtract(const Duration(days: 4)),
        notes: 'Do not rotate or relocate unnecessarily.',
        healthScore: 84,
        emojiAvatar: '🌳',
        logs: [
          CareLog(
            id: 'log_5',
            type: CareType.fertilize,
            timestamp: now.subtract(const Duration(days: 10)),
            note: 'Added organic liquid seaweed fertilizer',
          ),
        ],
      ),
      Plant(
        id: 'plant_5',
        name: 'Pothos Trail',
        species: 'Golden Pothos',
        location: 'Balcony',
        category: 'Vine',
        waterIntervalDays: 6,
        mistIntervalDays: 3,
        fertilizeIntervalDays: 30,
        sunlight: SunlightLevel.indirectBright,
        lastWatered: now.subtract(const Duration(days: 1)),
        notes: 'Trailing gracefully over the bookshelf edge.',
        healthScore: 98,
        emojiAvatar: '🍃',
      ),
    ]);
  }

  // Getters
  List<Plant> get allPlants => List.unmodifiable(_plants);
  String get searchQuery => _searchQuery;
  String get selectedLocation => _selectedLocation;
  String get selectedCategory => _selectedCategory;
  int get careStreakDays => _careStreakDays;
  int get completedTodayCount => _completedTodayCount;

  List<String> get availableLocations {
    final set = {'All'};
    for (var p in _plants) {
      if (p.location.trim().isNotEmpty) {
        set.add(p.location.trim());
      }
    }
    return set.toList();
  }

  List<String> get availableCategories {
    final set = {'All'};
    for (var p in _plants) {
      if (p.category.trim().isNotEmpty) {
        set.add(p.category.trim());
      }
    }
    return set.toList();
  }

  // Filtered Plants
  List<Plant> get filteredPlants {
    return _plants.where((plant) {
      final matchesSearch = _searchQuery.isEmpty ||
          plant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          plant.species.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          plant.location.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesLocation =
          _selectedLocation == 'All' || plant.location == _selectedLocation;
      final matchesCategory =
          _selectedCategory == 'All' || plant.category == _selectedCategory;

      return matchesSearch && matchesLocation && matchesCategory;
    }).toList();
  }

  // Overall metrics
  int get totalPlants => _plants.length;

  int get urgentWaterCount {
    return _plants.where((p) => p.daysUntilWater <= 0).length;
  }

  double get averageGardenHealth {
    if (_plants.isEmpty) return 100.0;
    final total = _plants.fold<int>(0, (sum, p) => sum + p.healthScore);
    return (total / _plants.length).clamp(0, 100);
  }

  // Care Reminders
  List<CareReminderTask> get allCareTasks {
    final List<CareReminderTask> tasks = [];
    for (var plant in _plants) {
      // Watering reminder
      tasks.add(
        CareReminderTask(
          id: '${plant.id}_water',
          plantId: plant.id,
          plantName: plant.name,
          species: plant.species,
          location: plant.location,
          emojiAvatar: plant.emojiAvatar,
          careType: CareType.water,
          dueDate: plant.nextWaterDate,
          isCompleted: false,
        ),
      );

      // Misting reminder (if configured)
      if (plant.mistIntervalDays > 0) {
        final lastMist = plant.lastMisted ?? plant.lastWatered;
        final nextMist = lastMist.add(Duration(days: plant.mistIntervalDays));
        tasks.add(
          CareReminderTask(
            id: '${plant.id}_mist',
            plantId: plant.id,
            plantName: plant.name,
            species: plant.species,
            location: plant.location,
            emojiAvatar: plant.emojiAvatar,
            careType: CareType.mist,
            dueDate: nextMist,
            isCompleted: false,
          ),
        );
      }
    }

    // Sort: overdue first, then due today, then upcoming
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }

  List<CareReminderTask> get urgentAndTodayTasks {
    return allCareTasks.where((task) => task.daysUntilDue <= 0).toList();
  }

  List<CareReminderTask> get upcomingTasks {
    return allCareTasks
        .where((task) => task.daysUntilDue > 0 && task.daysUntilDue <= 3)
        .toList();
  }

  // Filter setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // CRUD Operations
  void addPlant(Plant plant) {
    _plants.insert(0, plant);
    notifyListeners();
  }

  void updatePlant(Plant updatedPlant) {
    final index = _plants.indexWhere((p) => p.id == updatedPlant.id);
    if (index != -1) {
      _plants[index] = updatedPlant;
      notifyListeners();
    }
  }

  void deletePlant(String id) {
    _plants.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Plant? getPlantById(String id) {
    try {
      return _plants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Care actions
  void waterPlant(String id, {String? note}) {
    final plant = getPlantById(id);
    if (plant != null) {
      plant.water(note: note);
      _completedTodayCount++;
      notifyListeners();
    }
  }

  void mistPlant(String id, {String? note}) {
    final plant = getPlantById(id);
    if (plant != null) {
      plant.mist(note: note);
      _completedTodayCount++;
      notifyListeners();
    }
  }

  void fertilizePlant(String id, {String? note}) {
    final plant = getPlantById(id);
    if (plant != null) {
      plant.fertilize(note: note);
      _completedTodayCount++;
      notifyListeners();
    }
  }

  void performCare(String plantId, CareType type, {String? note}) {
    switch (type) {
      case CareType.water:
        waterPlant(plantId, note: note);
        break;
      case CareType.mist:
        mistPlant(plantId, note: note);
        break;
      case CareType.fertilize:
        fertilizePlant(plantId, note: note);
        break;
      case CareType.repot:
      case CareType.sunlight:
        final plant = getPlantById(plantId);
        if (plant != null) {
          plant.logs.insert(
            0,
            CareLog(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: type,
              timestamp: DateTime.now(),
              note: note ?? '${type.displayName} completed',
            ),
          );
          _completedTodayCount++;
          notifyListeners();
        }
        break;
    }
  }
}
