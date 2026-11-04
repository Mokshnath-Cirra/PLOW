class PlantSpecies {
  final String id;
  final String commonName;
  final Map<String, dynamic> localNames;
  final String scientificName;
  final String family;
  final String type;
  final String light;
  final int waterFrequencyDays;
  final String waterNotes;
  final String soil;
  final String temperatureRange;
  final String humidity;
  final String fertilizer;
  final String toxicityPets;
  final String toxicityHumans;
  final List<String> commonDiseases;
  final String growthNotes;
  final String funFact;

  const PlantSpecies({
    required this.id,
    required this.commonName,
    required this.localNames,
    required this.scientificName,
    required this.family,
    required this.type,
    required this.light,
    required this.waterFrequencyDays,
    required this.waterNotes,
    required this.soil,
    required this.temperatureRange,
    required this.humidity,
    required this.fertilizer,
    required this.toxicityPets,
    required this.toxicityHumans,
    required this.commonDiseases,
    required this.growthNotes,
    required this.funFact,
  });

  factory PlantSpecies.fromJson(Map<String, dynamic> json) {
    return PlantSpecies(
      id: json['id'] as String? ?? '',
      commonName: json['commonName'] as String? ?? json['common_name'] as String? ?? 'Unknown',
      localNames: json['local_names'] as Map<String, dynamic>? ?? {},
      scientificName: json['scientific_name'] as String? ?? '',
      family: json['family'] as String? ?? '',
      type: json['type'] as String? ?? 'houseplant',
      light: json['light'] as String? ?? '',
      waterFrequencyDays: (json['water_frequency_days'] as num?)?.toInt() ?? 7,
      waterNotes: json['water_notes'] as String? ?? '',
      soil: json['soil'] as String? ?? '',
      temperatureRange: json['temperature_range'] as String? ?? '',
      humidity: json['humidity'] as String? ?? '',
      fertilizer: json['fertilizer'] as String? ?? '',
      toxicityPets: json['toxicity_pets'] as String? ?? '',
      toxicityHumans: json['toxicity_humans'] as String? ?? '',
      commonDiseases: List<String>.from(json['common_diseases'] as List? ?? []),
      growthNotes: json['growth_notes'] as String? ?? '',
      funFact: json['fun_fact'] as String? ?? '',
    );
  }

  String get localizedDisplayName {
    if (localNames.containsKey('hindi') && (localNames['hindi'] as String).isNotEmpty) {
      return '$commonName (${localNames['hindi']})';
    }
    return commonName;
  }
}

class PlantDisease {
  final String id;
  final String name;
  final String scientificName;
  final String type;
  final List<String> cropsAffected;
  final List<String> symptoms;
  final List<String> causes;
  final String treatmentOrganic;
  final String treatmentChemical;
  final String prevention;

  const PlantDisease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.type,
    required this.cropsAffected,
    required this.symptoms,
    required this.causes,
    required this.treatmentOrganic,
    required this.treatmentChemical,
    required this.prevention,
  });

  factory PlantDisease.fromJson(Map<String, dynamic> json) {
    return PlantDisease(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Disease',
      scientificName: json['scientific_name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      cropsAffected: List<String>.from(json['crops_affected'] as List? ?? []),
      symptoms: List<String>.from(json['symptoms'] as List? ?? []),
      causes: List<String>.from(json['causes'] as List? ?? []),
      treatmentOrganic: json['treatment_organic'] as String? ?? '',
      treatmentChemical: json['treatment_chemical'] as String? ?? '',
      prevention: json['prevention'] as String? ?? '',
    );
  }
}
