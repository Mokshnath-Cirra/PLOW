import 'package:flutter_test/flutter_test.dart';
import 'package:plow_plant_care/models/plant.dart';
import 'package:plow_plant_care/providers/plant_provider.dart';

void main() {
  group('Plant Model & Provider Tests (Lab Session 10)', () {
    late PlantProvider provider;

    setUp(() {
      provider = PlantProvider();
    });

    test('Initial sample plants loaded successfully', () {
      expect(provider.allPlants.isNotEmpty, isTrue);
      expect(provider.totalPlants, greaterThanOrEqualTo(5));
    });

    test('Add new plant to garden increases plant count', () {
      final initialCount = provider.totalPlants;
      final newPlant = Plant(
        id: 'test_plant_1',
        name: 'Bonsai Jade',
        species: 'Crassula ovata',
        location: 'Study Desk',
        category: 'Succulent',
        waterIntervalDays: 10,
        lastWatered: DateTime.now(),
      );

      provider.addPlant(newPlant);
      expect(provider.totalPlants, equals(initialCount + 1));
      expect(provider.getPlantById('test_plant_1'), isNotNull);
      expect(provider.getPlantById('test_plant_1')!.name, equals('Bonsai Jade'));
    });

    test('Watering plant updates lastWatered and creates care log entry', () {
      final plant = provider.allPlants.first;
      final initialLogCount = plant.logs.length;

      provider.waterPlant(plant.id, note: 'Test water watering cycle');

      final updatedPlant = provider.getPlantById(plant.id);
      expect(updatedPlant, isNotNull);
      expect(updatedPlant!.logs.length, equals(initialLogCount + 1));
      expect(updatedPlant.logs.first.type, equals(CareType.water));
      expect(updatedPlant.daysUntilWater, equals(updatedPlant.waterIntervalDays));
    });

    test('Search filter properly filters plants by query', () {
      provider.setSearchQuery('Monstera');
      expect(provider.filteredPlants.length, equals(1));
      expect(provider.filteredPlants.first.species, contains('Monstera'));

      provider.setSearchQuery('');
      expect(provider.filteredPlants.length, equals(provider.allPlants.length));
    });

    test('Location filter properly isolates plants by room', () {
      provider.setSelectedLocation('Living Room');
      for (var p in provider.filteredPlants) {
        expect(p.location, equals('Living Room'));
      }
    });
  });
}
