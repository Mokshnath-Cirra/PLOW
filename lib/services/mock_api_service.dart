import 'dart:async';
import '../models/plant_guide.dart';

class PlantApiService {
  // Simulates a REST API call with realistic latency and JSON parsing
  static Future<List<PlantGuideItem>> fetchPlantGuides({
    String? query,
    String? category,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    final List<Map<String, dynamic>> rawData = [
      {
        'id': 1,
        'commonName': 'Monstera Deliciosa',
        'scientificName': 'Monstera deliciosa',
        'category': 'Tropical',
        'lightRequirement': 'Bright, indirect sunlight',
        'wateringFrequency': 'Every 7-10 days',
        'humidityLevel': '60% - 80% (Moderate to High)',
        'difficulty': 'Beginner Friendly',
        'toxicity': 'Toxic to cats and dogs if ingested',
        'careSummary':
            'Famous for its iconic perforated leaves (fenestrations). Thrives in warm, humid spaces with gentle morning light.',
        'proTips': [
          'Wipe dust off leaves once every two weeks to encourage photosynthesis.',
          'Provide a moss pole as it matures to support aerial roots and encourage larger leaves.',
          'Allow the top 2 inches of soil to dry out between waterings to prevent root rot.'
        ],
        'iconEmoji': '🪴',
      },
      {
        'id': 2,
        'commonName': 'Snake Plant (Sansevieria)',
        'scientificName': 'Dracaena trifasciata',
        'category': 'Succulent',
        'lightRequirement': 'Low light to bright indirect',
        'wateringFrequency': 'Every 14-21 days',
        'humidityLevel': '30% - 50% (Standard room humidity)',
        'difficulty': 'Super Easy (Indestructible)',
        'toxicity': 'Mildly toxic to pets',
        'careSummary':
            'One of the most resilient indoor plants in existence. Purifies air and tolerates severe neglect.',
        'proTips': [
          'Less is definitely more! Only water when the soil is bone dry all the way to the bottom.',
          'Thrives in virtually any lighting condition, from dim bedrooms to sunny balconies.',
          'Avoid getting water in the center rosette to protect against crown rot.'
        ],
        'iconEmoji': '🌿',
      },
      {
        'id': 3,
        'commonName': 'Peace Lily',
        'scientificName': 'Spathiphyllum wallisii',
        'category': 'Flowering',
        'lightRequirement': 'Medium indirect light to deep shade',
        'wateringFrequency': 'Every 5-7 days',
        'humidityLevel': '50% - 70% (Prefers misting)',
        'difficulty': 'Moderate',
        'toxicity': 'Toxic to pets',
        'careSummary':
            'Elegant glossy foliage with pristine white spathes. Dramatically droops when thirsty, making care intuitive.',
        'proTips': [
          'Use filtered or distilled water if leaf tips develop brown edges from tap chlorine.',
          'If the leaves suddenly droop, a generous drink will perk it back up within hours.',
          'Keep away from cold drafts and direct air conditioner vents.'
        ],
        'iconEmoji': '🪷',
      },
      {
        'id': 4,
        'commonName': 'ZZ Plant (Zanzibar Gem)',
        'scientificName': 'Zamioculcas zamiifolia',
        'category': 'Indoor',
        'lightRequirement': 'Low to bright indirect light',
        'wateringFrequency': 'Every 14-20 days',
        'humidityLevel': 'Average indoor humidity (40%)',
        'difficulty': 'Beginner Friendly',
        'toxicity': 'Toxic if consumed in large quantities',
        'careSummary':
            'Features naturally shiny, waxy foliage that looks polished. Potato-like underground rhizomes store water for weeks.',
        'proTips': [
          'Will happily thrive under artificial fluorescent office lighting.',
          'Yellowing stems are an immediate warning sign of overwatering.',
          'Requires minimal fertilizer - once in spring and once in summer is plenty.'
        ],
        'iconEmoji': '🌱',
      },
      {
        'id': 5,
        'commonName': 'Fiddle Leaf Fig',
        'scientificName': 'Ficus lyrata',
        'category': 'Tree / Indoor',
        'lightRequirement': 'Very bright, consistent indirect light',
        'wateringFrequency': 'Every 7-10 days',
        'humidityLevel': '55% - 75%',
        'difficulty': 'Challenging (Drama Queen)',
        'toxicity': 'Toxic to dogs and cats',
        'careSummary':
            'A showstopper architectural statement plant. Loves stability and dislikes being moved around once settled.',
        'proTips': [
          'Rotate 90 degrees every week so all sides receive balanced light exposure.',
          'Avoid sudden drafts or temperature fluctuations to prevent leaf dropping.',
          'Only water when top 2-3 inches of potting medium feels dry.'
        ],
        'iconEmoji': '🌳',
      },
      {
        'id': 6,
        'commonName': 'Boston Fern',
        'scientificName': 'Nephrolepis exaltata',
        'category': 'Fern',
        'lightRequirement': 'Gentle morning light or dappled shade',
        'wateringFrequency': 'Every 3-5 days',
        'humidityLevel': '70% - 90% (Loves humidity)',
        'difficulty': 'Moderate',
        'toxicity': 'Non-toxic (Pet safe!)',
        'careSummary':
            'Lush, cascading frills of vibrant green fronds. Perfect for bathroom hanging baskets and steamy windowsills.',
        'proTips': [
          'Keep soil consistently moist like a wrung-out sponge, never soggy or bone dry.',
          'Mist frequently or set on a pebble tray filled with water.',
          'Completely safe for curious furry companions!'
        ],
        'iconEmoji': '🪴',
      },
      {
        'id': 7,
        'commonName': 'Golden Pothos (Devil\'s Ivy)',
        'scientificName': 'Epipremnum aureum',
        'category': 'Indoor / Vine',
        'lightRequirement': 'Adaptable to almost all light levels',
        'wateringFrequency': 'Every 7-10 days',
        'humidityLevel': '40% - 60%',
        'difficulty': 'Super Easy',
        'toxicity': 'Mildly toxic to pets',
        'careSummary':
            'Fast-growing cascading vine with heart-shaped leaves variegated with golden specks. Effortless to propagate in water.',
        'proTips': [
          'Propagate easily by snipping below any aerial root node and placing in a glass of water.',
          'Will grow in low light, but variegation increases with brighter indirect light.',
          'Pinch trailing stems occasionally to encourage bushy, fuller growth.'
        ],
        'iconEmoji': '🍃',
      },
    ];

    List<PlantGuideItem> items =
        rawData.map((json) => PlantGuideItem.fromJson(json)).toList();

    if (query != null && query.trim().isNotEmpty) {
      final cleanQuery = query.toLowerCase().trim();
      items = items.where((p) {
        return p.commonName.toLowerCase().contains(cleanQuery) ||
            p.scientificName.toLowerCase().contains(cleanQuery) ||
            p.category.toLowerCase().contains(cleanQuery) ||
            p.careSummary.toLowerCase().contains(cleanQuery);
      }).toList();
    }

    if (category != null && category != 'All') {
      items = items.where((p) => p.category.toLowerCase().contains(category.toLowerCase())).toList();
    }

    return items;
  }
}
