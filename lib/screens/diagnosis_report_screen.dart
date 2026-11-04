import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/diagnosis_report.dart';
import '../providers/plant_provider.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';

class DiagnosisReportScreen extends StatefulWidget {
  final DiagnosisReport? report;
  final String? specimenKey;

  const DiagnosisReportScreen({
    super.key,
    this.report,
    this.specimenKey,
  });

  @override
  State<DiagnosisReportScreen> createState() => _DiagnosisReportScreenState();
}

class _DiagnosisReportScreenState extends State<DiagnosisReportScreen> {
  late DiagnosisReport _report;
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  bool _isChatLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      _report = widget.report!;
    } else {
      // Fallback default sample
      _report = const DiagnosisReport(
        isPlant: true,
        commonName: 'Tomato',
        scientificName: 'Solanum lycopersicum',
        family: 'Solanaceae',
        plantType: 'crop',
        confidence: 94.2,
        healthStatus: 'diseased',
        diseaseName: 'Early Blight',
        diseaseConfidence: 92.0,
        symptomsSeen: ['Concentric dark brown bullseye lesions', 'Yellow chlorotic halos around lesions'],
        severity: 64,
        likelyCauses: [
          'High ambient humidity and leaf surface wetness exceeding 4 hours',
          'Soil-borne fungal spores splashing onto foliage',
        ],
        treatmentSteps: [
          'Prune and discard infected lower foliage using sanitized shears',
          'Apply organic copper octanoate or Bacillus subtilis spray every 7 days',
          'Transition from overhead watering to basal soil drip irrigation',
        ],
        preventionTips: [
          'Water only at root level early in the morning',
          'Space plants 24 inches apart for maximum airflow',
          'Apply 2 inches of organic straw mulch',
        ],
        timestamp: 'Just now',
      );
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendChatMessage() async {
    final query = _chatController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _chatMessages.add({'role': 'user', 'text': query});
      _chatController.clear();
      _isChatLoading = true;
    });

    final reply = await PlantApiService().askAgronomist(
      question: query,
      contextReport: _report,
    );

    if (mounted) {
      setState(() {
        _chatMessages.add({'role': 'assistant', 'text': reply});
        _isChatLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: _report.isLowConfidence ? AppColors.warning : AppColors.primaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                'AI CONFIDENCE ${_report.confidence.toInt()}%',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: ResponsiveContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NOT A PLANT ERROR BANNER
              if (!_report.isPlant) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.urgent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.urgent, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.urgent),
                      const SizedBox(height: 10),
                      const Text(
                        'Not a Plant',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.urgent),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The uploaded image does not appear to be a plant, leaf, tree, or crop (Identified as: ${_report.commonName}). Please upload a clear photo of living foliage.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 1. PRIMARY PLANT IDENTIFICATION CARD
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _report.plantType.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ),
                                    if (_report.isCareVerified) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          '✓ Verified Botanical Match',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _report.commonName,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (_report.scientificName.isNotEmpty)
                                  Text(
                                    _report.scientificName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _report.isHealthy ? Colors.green.shade50 : AppColors.urgent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _report.isHealthy ? '🌱' : '⚠️',
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Low confidence warning & alternatives
                      if (_report.isLowConfidence) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '⚠️ Not sure, here are the closest matches:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              if (_report.alternatives.isNotEmpty)
                                ..._report.alternatives.map((alt) => Text(
                                      '• ${alt.name} (${alt.confidence.toInt()}% match)',
                                      style: const TextStyle(fontSize: 11),
                                    ))
                              else
                                const Text('• Take a clearer close-up photo of the leaf in natural daylight for higher confidence.', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Add to Garden Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (_report.matchedSpecies != null) {
                              context.read<PlantProvider>().addPlantFromSpecies(_report.matchedSpecies!);
                            } else {
                              context.read<PlantProvider>().addPlantFromSpecies(
                                    PlantSpecies(
                                      id: 'id_${DateTime.now().millisecondsSinceEpoch}',
                                      commonName: _report.commonName,
                                      localNames: {},
                                      scientificName: _report.scientificName,
                                      family: _report.family,
                                      type: _report.plantType,
                                      light: 'Bright indirect light',
                                      waterFrequencyDays: 7,
                                      waterNotes: 'Care data from AI, not verified',
                                      soil: 'Well-draining potting mix',
                                      temperatureRange: '18°C - 30°C',
                                      humidity: '50% - 70%',
                                      fertilizer: 'Balanced organic fertilizer',
                                      toxicityPets: 'Unknown',
                                      toxicityHumans: 'Unknown',
                                      commonDiseases: [],
                                      growthNotes: 'Added from AI diagnosis',
                                      funFact: '',
                                    ),
                                  );
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🌱 Added ${_report.commonName} to My Garden!'),
                                backgroundColor: AppColors.primaryGreen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_task_rounded),
                          label: const Text('Add to My Garden Schedule'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. HEALTH STATUS / DISEASE DIAGNOSIS
              if (_report.isHealthy) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.green),
                      SizedBox(height: 10),
                      Text(
                        'Plant is Healthy & Thriving!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.green),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'No pathogens, fungal spots, or stress symptoms detected. Foliage shows balanced chlorophyll development.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_report.diseaseName != null) ...[
                // DISEASE IDENTIFICATION CARD
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'DETECTED PATHOLOGICAL CONDITION',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.urgent, letterSpacing: 0.5),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.urgent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Severity: ${_report.severity}%',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.urgent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _report.diseaseName!,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),

                        // Symptoms
                        if (_report.symptomsSeen.isNotEmpty) ...[
                          const Text('Symptoms Detected:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ..._report.symptomsSeen.map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: AppColors.urgent, fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(s, style: const TextStyle(fontSize: 12))),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 12),
                        ],

                        // Likely Causes
                        if (_report.likelyCauses.isNotEmpty) ...[
                          const Text('Likely Underlying Causes:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ..._report.likelyCauses.map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(c, style: const TextStyle(fontSize: 12))),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. TREATMENT STEPS & SPRAY PLAN
                if (_report.treatmentSteps.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💊 TREATMENT SOLUTIONS & PRESCRIPTION',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryLight, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 10),
                          ..._report.treatmentSteps.asMap().entries.map((entry) {
                            final idx = entry.key + 1;
                            final step = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: AppColors.primaryGreen,
                                    child: Text('$idx', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(step, style: const TextStyle(fontSize: 13, height: 1.4))),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. PREVENTION GUIDE
                if (_report.preventionTips.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🛡️ PREVENTION GUIDE & ENVIRONMENTAL CARE',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accentEmerald, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 10),
                          ..._report.preventionTips.map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primaryLight),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, height: 1.4))),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],

              // 5. AGRONOMIST AI CHAT
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('👨‍🌾', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ask Agronomist AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('Instant follow-up advice tailored to this plant', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Chat message history
                      if (_chatMessages.isNotEmpty) ...[
                        ..._chatMessages.map((m) {
                          final isUser = m['role'] == 'user';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppColors.primaryGreen.withOpacity(0.12)
                                  : (isDark ? AppColors.darkCard : AppColors.lightBg),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              m['text']!,
                              style: TextStyle(fontSize: 12, height: 1.4, fontWeight: isUser ? FontWeight.w600 : FontWeight.normal),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],

                      if (_isChatLoading) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              SizedBox(width: 10),
                              Text('Agronomist is analyzing...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],

                      // Chat input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              onSubmitted: (_) => _sendChatMessage(),
                              decoration: const InputDecoration(
                                hintText: 'Ask about watering, fertilizers, or pruning...',
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: AppColors.primaryGreen),
                            onPressed: _sendChatMessage,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
