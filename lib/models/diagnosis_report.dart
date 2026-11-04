import 'plant_species.dart';

class AlternativeMatch {
  final String name;
  final double confidence;

  const AlternativeMatch({required this.name, required this.confidence});

  factory AlternativeMatch.fromJson(Map<String, dynamic> json) {
    return AlternativeMatch(
      name: json['name'] as String? ?? 'Alternative',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 50.0,
    );
  }
}

class DiagnosisReport {
  final bool isPlant;
  final String commonName;
  final String scientificName;
  final String family;
  final String plantType;
  final double confidence;
  final String healthStatus; // "healthy" | "diseased" | "stressed" | "unknown"
  final String? diseaseName;
  final double diseaseConfidence;
  final List<String> symptomsSeen;
  final int severity; // 0 - 100
  final List<String> likelyCauses;
  final List<String> treatmentSteps;
  final List<String> preventionTips;
  final List<AlternativeMatch> alternatives;
  final PlantSpecies? matchedSpecies;
  final bool isCareVerified;
  final String? imageUrl;
  final String timestamp;

  const DiagnosisReport({
    required this.isPlant,
    required this.commonName,
    required this.scientificName,
    required this.family,
    required this.plantType,
    required this.confidence,
    required this.healthStatus,
    this.diseaseName,
    this.diseaseConfidence = 0.0,
    required this.symptomsSeen,
    required this.severity,
    required this.likelyCauses,
    required this.treatmentSteps,
    required this.preventionTips,
    this.alternatives = const [],
    this.matchedSpecies,
    this.isCareVerified = false,
    this.imageUrl,
    required this.timestamp,
  });

  bool get isHealthy => healthStatus.toLowerCase() == 'healthy' || (diseaseName == null && severity == 0);
  bool get isLowConfidence => confidence < 60.0;

  factory DiagnosisReport.fromJson(Map<String, dynamic> json, {String? imagePath}) {
    final alts = (json['alternatives'] as List? ?? [])
        .map((e) => AlternativeMatch.fromJson(e as Map<String, dynamic>))
        .toList();

    return DiagnosisReport(
      isPlant: json['is_plant'] as bool? ?? true,
      commonName: json['common_name'] as String? ?? 'Unknown Specimen',
      scientificName: json['scientific_name'] as String? ?? '',
      family: json['family'] as String? ?? '',
      plantType: json['plant_type'] as String? ?? 'other',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 75.0,
      healthStatus: json['health_status'] as String? ?? 'unknown',
      diseaseName: json['disease_name'] as String?,
      diseaseConfidence: (json['disease_confidence'] as num?)?.toDouble() ?? 0.0,
      symptomsSeen: List<String>.from(json['symptoms_seen'] as List? ?? []),
      severity: (json['severity'] as num?)?.toInt() ?? 0,
      likelyCauses: List<String>.from(json['likely_causes'] as List? ?? []),
      treatmentSteps: List<String>.from(json['treatment_steps'] as List? ?? []),
      preventionTips: List<String>.from(json['prevention_tips'] as List? ?? []),
      alternatives: alts,
      imageUrl: imagePath,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  DiagnosisReport copyWithMergedSpecies(PlantSpecies species) {
    return DiagnosisReport(
      isPlant: isPlant,
      commonName: commonName,
      scientificName: scientificName.isNotEmpty ? scientificName : species.scientificName,
      family: family.isNotEmpty ? family : species.family,
      plantType: plantType.isNotEmpty ? plantType : species.type,
      confidence: confidence,
      healthStatus: healthStatus,
      diseaseName: diseaseName,
      diseaseConfidence: diseaseConfidence,
      symptomsSeen: symptomsSeen,
      severity: severity,
      likelyCauses: likelyCauses,
      treatmentSteps: treatmentSteps.isNotEmpty ? treatmentSteps : [species.growthNotes],
      preventionTips: preventionTips.isNotEmpty ? preventionTips : [species.waterNotes, species.fertilizer],
      alternatives: alternatives,
      matchedSpecies: species,
      isCareVerified: true,
      imageUrl: imageUrl,
      timestamp: timestamp,
    );
  }
}
