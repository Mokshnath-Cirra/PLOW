class PlantGuideItem {
  final int id;
  final String commonName;
  final String scientificName;
  final String category;
  final String lightRequirement;
  final String wateringFrequency;
  final String humidityLevel;
  final String difficulty;
  final String toxicity;
  final String careSummary;
  final List<String> proTips;
  final String iconEmoji;

  const PlantGuideItem({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.category,
    required this.lightRequirement,
    required this.wateringFrequency,
    required this.humidityLevel,
    required this.difficulty,
    required this.toxicity,
    required this.careSummary,
    required this.proTips,
    required this.iconEmoji,
  });

  factory PlantGuideItem.fromJson(Map<String, dynamic> json) {
    return PlantGuideItem(
      id: json['id'] as int,
      commonName: json['commonName'] as String,
      scientificName: json['scientificName'] as String,
      category: json['category'] as String,
      lightRequirement: json['lightRequirement'] as String,
      wateringFrequency: json['wateringFrequency'] as String,
      humidityLevel: json['humidityLevel'] as String,
      difficulty: json['difficulty'] as String,
      toxicity: json['toxicity'] as String,
      careSummary: json['careSummary'] as String,
      proTips: List<String>.from(json['proTips'] as List),
      iconEmoji: json['iconEmoji'] as String? ?? '🌱',
    );
  }
}
