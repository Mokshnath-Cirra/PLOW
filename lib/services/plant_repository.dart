import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/plant_species.dart';
import '../models/diagnosis_report.dart';

class PlantRepository {
  static final PlantRepository _instance = PlantRepository._internal();
  factory PlantRepository() => _instance;
  PlantRepository._internal();

  List<PlantSpecies> _plants = [];
  List<PlantDisease> _diseases = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<PlantSpecies> get allPlants => List.unmodifiable(_plants);
  List<PlantDisease> get allDiseases => List.unmodifiable(_diseases);

  Future<void> initialize() async {
    if (_isLoaded) return;
    try {
      final plantsRaw = await rootBundle.loadString('assets/data/plants.json');
      final List<dynamic> plantsJson = json.decode(plantsRaw);
      _plants = plantsJson.map((e) => PlantSpecies.fromJson(e as Map<String, dynamic>)).toList();

      final diseasesRaw = await rootBundle.loadString('assets/data/diseases.json');
      final List<dynamic> diseasesJson = json.decode(diseasesRaw);
      _diseases = diseasesJson.map((e) => PlantDisease.fromJson(e as Map<String, dynamic>)).toList();

      _isLoaded = true;
    } catch (e) {
      // In web preview or test mode if rootBundle fails, load fallback data
      _isLoaded = false;
    }
  }

  void loadFromRawList(List<Map<String, dynamic>> rawPlants, List<Map<String, dynamic>> rawDiseases) {
    _plants = rawPlants.map((e) => PlantSpecies.fromJson(e)).toList();
    _diseases = rawDiseases.map((e) => PlantDisease.fromJson(e)).toList();
    _isLoaded = true;
  }

  PlantSpecies? findFuzzyMatch(String query) {
    if (query.trim().isEmpty || _plants.isEmpty) return null;
    final clean = query.toLowerCase().trim();

    // 1. Exact match on scientific name or common name
    for (var p in _plants) {
      if (p.scientificName.toLowerCase() == clean || p.commonName.toLowerCase() == clean) {
        return p;
      }
    }

    // 2. Contains match
    for (var p in _plants) {
      final pCommon = p.commonName.toLowerCase();
      final pSci = p.scientificName.toLowerCase();
      if (pCommon.contains(clean) || clean.contains(pCommon)) return p;
      if (pSci.contains(clean) || clean.contains(pSci)) return p;

      // Check local names (Hindi, Telugu, Kannada)
      for (var val in p.localNames.values) {
        if (val is String && val.toLowerCase().contains(clean)) return p;
      }
    }

    // 3. Token match
    final queryTokens = clean.split(RegExp(r'\s+')).where((t) => t.length > 2).toList();
    for (var p in _plants) {
      final text = '${p.commonName} ${p.scientificName} ${p.localNames.values.join(" ")}'.toLowerCase();
      for (var token in queryTokens) {
        if (text.contains(token)) return p;
      }
    }

    return null;
  }

  DiagnosisReport enrichDiagnosis(DiagnosisReport report) {
    final match = findFuzzyMatch(report.commonName) ?? findFuzzyMatch(report.scientificName);
    if (match != null) {
      return report.copyWithMergedSpecies(match);
    }
    return report;
  }

  List<PlantSpecies> searchPlants({String? query, String? type}) {
    return _plants.where((p) {
      final matchesQuery = query == null ||
          query.trim().isEmpty ||
          p.commonName.toLowerCase().contains(query.toLowerCase()) ||
          p.scientificName.toLowerCase().contains(query.toLowerCase()) ||
          p.family.toLowerCase().contains(query.toLowerCase());

      final matchesType = type == null || type == 'All' || p.type.toLowerCase() == type.toLowerCase();
      return matchesQuery && matchesType;
    }).toList();
  }

  List<String> get availableTypes {
    final types = {'All'};
    for (var p in _plants) {
      if (p.type.isNotEmpty) types.add(p.type);
    }
    return types.toList();
  }
}
