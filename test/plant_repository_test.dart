import 'package:flutter_test/flutter_test.dart';
import 'package:plow_plant_care/models/plant_species.dart';
import 'package:plow_plant_care/models/diagnosis_report.dart';
import 'package:plow_plant_care/services/plant_repository.dart';

void main() {
  group('PlantSpecies and PlantDisease JSON Parsing Tests', () {
    test('PlantSpecies parses complete JSON schema correctly', () {
      final jsonSample = {
        'id': 'tulsi-01',
        'common_name': 'Holy Basil (Tulsi)',
        'local_names': {
          'hindi': 'तुलसी (Tulsi)',
          'telugu': 'తులసి (Tulasi)',
          'kannada': 'ತುಳಸಿ (Tulasi)'
        },
        'scientific_name': 'Ocimum tenuiflorum',
        'family': 'Lamiaceae',
        'type': 'herb',
        'light': 'Full sun (6+ hours)',
        'water_frequency_days': 2,
        'water_notes': 'Keep soil moist but well-drained. Water daily in hot Indian summers.',
        'soil': 'Rich, loamy, well-draining soil with organic compost',
        'temperature_range': '20°C - 35°C',
        'humidity': '50% - 70%',
        'fertilizer': 'Organic cow dung manure or vermicompost every 3 weeks',
        'toxicity_pets': 'Non-toxic',
        'toxicity_humans': 'Non-toxic (medicinal herb)',
        'common_diseases': ['powdery-mildew-01', 'root-rot-01'],
        'growth_notes': 'Pinch off flower tips (manjari) regularly to encourage bushy foliage.',
        'fun_fact': 'Sacred herb in Ayurveda revered as the Queen of Herbs.'
      };

      final species = PlantSpecies.fromJson(jsonSample);
      expect(species.id, equals('tulsi-01'));
      expect(species.commonName, equals('Holy Basil (Tulsi)'));
      expect(species.scientificName, equals('Ocimum tenuiflorum'));
      expect(species.waterFrequencyDays, equals(2));
      expect(species.localNames['hindi'], contains('तुलसी'));
      expect(species.commonDiseases.length, equals(2));
    });

    test('PlantDisease parses complete JSON schema correctly', () {
      final jsonDisease = {
        'id': 'early-blight-01',
        'name': 'Early Blight',
        'pathogen_type': 'fungal',
        'scientific_name': 'Alternaria solani',
        'symptoms': [
          'Concentric dark brown bullseye rings on older leaves',
          'Yellowing halo around spots'
        ],
        'causes': ['Warm humid weather', 'Overhead watering splashing spores'],
        'organic_treatment': 'Neem oil spray, copper fungicide, pruning lower leaves',
        'chemical_treatment': 'Chlorothalonil or Mancozeb application',
        'prevention': 'Drip irrigation at base, 2-year crop rotation, stake plants'
      };

      final disease = PlantDisease.fromJson(jsonDisease);
      expect(disease.id, equals('early-blight-01'));
      expect(disease.name, equals('Early Blight'));
      expect(disease.pathogenType, equals('fungal'));
      expect(disease.symptoms.length, equals(2));
      expect(disease.organicTreatment, contains('Neem oil'));
    });
  });

  group('PlantRepository Fuzzy Matching Tests', () {
    late PlantRepository repo;

    setUp(() {
      repo = PlantRepository();
      repo.loadFromRawList(
        [
          {
            'id': 'tulsi-01',
            'common_name': 'Holy Basil (Tulsi)',
            'local_names': {
              'hindi': 'Tulsi',
              'telugu': 'Tulasi',
              'kannada': 'Tulasi'
            },
            'scientific_name': 'Ocimum tenuiflorum',
            'family': 'Lamiaceae',
            'type': 'herb',
            'light': 'Full sun',
            'water_frequency_days': 2,
            'water_notes': 'Keep moist',
            'soil': 'Loamy',
            'temperature_range': '20-35C',
            'humidity': 'Moderate',
            'fertilizer': 'Vermicompost',
            'toxicity_pets': 'Safe',
            'toxicity_humans': 'Safe',
            'common_diseases': [],
            'growth_notes': 'Pinch flowers',
            'fun_fact': 'Sacred herb'
          },
          {
            'id': 'tomato-01',
            'common_name': 'Tomato',
            'local_names': {'hindi': 'Tamatar'},
            'scientific_name': 'Solanum lycopersicum',
            'family': 'Solanaceae',
            'type': 'crop',
            'light': 'Full sun',
            'water_frequency_days': 3,
            'water_notes': 'Deep water at base',
            'soil': 'Loam',
            'temperature_range': '18-30C',
            'humidity': 'Moderate',
            'fertilizer': 'High potassium',
            'toxicity_pets': 'Leaves toxic',
            'toxicity_humans': 'Fruit edible',
            'common_diseases': ['early-blight-01'],
            'growth_notes': 'Stake vines',
            'fun_fact': 'Botanically a berry'
          },
          {
            'id': 'neem-01',
            'common_name': 'Neem Tree',
            'local_names': {
              'hindi': 'Neem',
              'telugu': 'Vepa',
              'kannada': 'Bevina Mara'
            },
            'scientific_name': 'Azadirachta indica',
            'family': 'Meliaceae',
            'type': 'tree',
            'light': 'Full sun',
            'water_frequency_days': 7,
            'water_notes': 'Drought tolerant',
            'soil': 'Sandy loam',
            'temperature_range': '20-45C',
            'humidity': 'Low to high',
            'fertilizer': 'Rarely needed',
            'toxicity_pets': 'Non-toxic',
            'toxicity_humans': 'Medicinal',
            'common_diseases': [],
            'growth_notes': 'Fast growing',
            'fun_fact': 'Natural organic insecticide'
          }
        ],
        [],
      );
    });

    test('Exact match on common name', () {
      final match = repo.findFuzzyMatch('Tomato');
      expect(match, isNotNull);
      expect(match!.id, equals('tomato-01'));
    });

    test('Case-insensitive match on scientific name', () {
      final match = repo.findFuzzyMatch('ocimum tenuiflorum');
      expect(match, isNotNull);
      expect(match!.id, equals('tulsi-01'));
    });

    test('Fuzzy match on Indian local name (Hindi / Telugu)', () {
      final matchHindi = repo.findFuzzyMatch('tulsi');
      expect(matchHindi, isNotNull);
      expect(matchHindi!.id, equals('tulsi-01'));

      final matchTelugu = repo.findFuzzyMatch('vepa');
      expect(matchTelugu, isNotNull);
      expect(matchTelugu!.id, equals('neem-01'));
    });

    test('Enriches DiagnosisReport with verified database plant care', () {
      final aiReport = DiagnosisReport(
        isPlant: true,
        commonName: 'Holy Basil',
        scientificName: 'Ocimum sanctum',
        family: 'Lamiaceae',
        plantType: 'herb',
        confidence: 91,
        healthStatus: 'healthy',
        diseaseName: null,
        diseaseConfidence: 0,
        symptomsSeen: [],
        severity: 0,
        likelyCauses: [],
        treatmentSteps: ['General hydration'],
        preventionTips: ['Adequate sun'],
        alternatives: [],
        isVerifiedDbMatch: false,
      );

      final enriched = repo.enrichDiagnosis(aiReport);
      expect(enriched.isVerifiedDbMatch, isTrue);
      expect(enriched.matchedSpecies, isNotNull);
      expect(enriched.matchedSpecies!.id, equals('tulsi-01'));
      expect(enriched.matchedSpecies!.waterFrequencyDays, equals(2));
    });
  });
}
