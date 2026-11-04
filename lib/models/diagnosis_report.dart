class ProgressionStep {
  final String phaseTitle;
  final String status;
  final String description;
  final bool isResolved;
  final bool isActive;

  const ProgressionStep({
    required this.phaseTitle,
    required this.status,
    required this.description,
    this.isResolved = false,
    this.isActive = false,
  });
}

class EtiologyVector {
  final String title;
  final String description;
  final String iconEmoji;

  const EtiologyVector({
    required this.title,
    required this.description,
    required this.iconEmoji,
  });
}

class DiagnosisReport {
  final String id;
  final String cropName;
  final String location;
  final String diseaseName;
  final String scientificName;
  final String familyId;
  final String classification;
  final String timestamp;
  final String microclimate;
  final double aiConfidence;
  final int severityScore;
  final String stageBadge;
  final String alertLevel;
  final String summary;
  final String imageUrl;
  final List<ProgressionStep> progressionSteps;
  final List<EtiologyVector> etiologyVectors;
  final List<String> treatmentSteps;
  final List<String> preventionTips;

  const DiagnosisReport({
    required this.id,
    required this.cropName,
    required this.location,
    required this.diseaseName,
    required this.scientificName,
    required this.familyId,
    required this.classification,
    required this.timestamp,
    required this.microclimate,
    required this.aiConfidence,
    required this.severityScore,
    required this.stageBadge,
    required this.alertLevel,
    required this.summary,
    required this.imageUrl,
    required this.progressionSteps,
    required this.etiologyVectors,
    required this.treatmentSteps,
    required this.preventionTips,
  });
}
