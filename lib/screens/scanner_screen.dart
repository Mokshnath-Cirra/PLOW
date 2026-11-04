import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../models/diagnosis_report.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';
import 'diagnosis_report_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserAnim;
  final ImagePicker _picker = ImagePicker();
  final PlantApiService _apiService = PlantApiService();

  bool _isAnalyzing = false;
  String? _errorMessage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  // Labeled demo samples strictly for offline demonstration
  final List<Map<String, dynamic>> _demoSamples = [
    {
      'label': 'Tomato Blight (Demo)',
      'is_plant': true,
      'common_name': 'Tomato',
      'scientific_name': 'Solanum lycopersicum',
      'family': 'Solanaceae',
      'plant_type': 'crop',
      'confidence': 94.2,
      'health_status': 'diseased',
      'disease_name': 'Early Blight',
      'disease_confidence': 92.0,
      'symptoms_seen': ['Concentric bullseye lesions', 'Yellow chlorotic margins'],
      'severity': 64,
      'likely_causes': ['Prolonged leaf wetness', 'Soil fungal spores Alternaria solani'],
      'treatment_steps': ['Prune lower 3 leaves', 'Apply Liquid Copper Octanoate spray'],
      'prevention_tips': ['Drip irrigation only', 'Mulch soil surface 2 inches'],
      'image': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=800&auto=format&fit=crop',
    },
    {
      'label': 'Rose Mildew (Demo)',
      'is_plant': true,
      'common_name': 'Rose',
      'scientific_name': 'Rosa hybrida',
      'family': 'Rosaceae',
      'plant_type': 'flower',
      'confidence': 96.5,
      'health_status': 'diseased',
      'disease_name': 'Powdery Mildew',
      'disease_confidence': 95.0,
      'symptoms_seen': ['White talc powder mycelium on leaves', 'Leaf edge curling'],
      'severity': 45,
      'likely_causes': ['High ambient humidity with dry foliage', 'Stagnant air circulation'],
      'treatment_steps': ['Spray diluted neem oil or sulfur', 'Improve cross ventilation'],
      'prevention_tips': ['Prune dense inward canes', 'Place in full morning sun'],
      'image': 'https://images.unsplash.com/photo-1550950158-d0d960dff51b?w=800&auto=format&fit=crop',
    },
    {
      'label': 'Monstera Healthy (Demo)',
      'is_plant': true,
      'common_name': 'Monstera Deliciosa',
      'scientific_name': 'Monstera deliciosa',
      'family': 'Araceae',
      'plant_type': 'houseplant',
      'confidence': 98.0,
      'health_status': 'healthy',
      'disease_name': null,
      'disease_confidence': 0.0,
      'symptoms_seen': ['Vibrant deep green foliage with balanced fenestration'],
      'severity': 0,
      'likely_causes': ['Optimal indirect sunlight', 'Adequate watering schedule'],
      'treatment_steps': ['Continue routine weekly care'],
      'prevention_tips': ['Wipe dust off leaves once every 2 weeks'],
      'image': 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=800&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _laserAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void disposenatural() {
    _laserAnim.dispose();
  }

  @override
  void dispose() {
    _laserAnim.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = file.name;
        _isAnalyzing = true;
      });

      // Send to FastAPI real vision endpoint
      final report = await _apiService.analyzeImage(bytes, file.name);

      if (mounted) {
        setState(() => _isAnalyzing = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiagnosisReportScreen(report: report),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _loadDemoSample(Map<String, dynamic> sample) {
    final report = DiagnosisReport(
      isPlant: sample['is_plant'] as bool,
      commonName: sample['common_name'] as String,
      scientificName: sample['scientific_name'] as String,
      family: sample['family'] as String,
      plantType: sample['plant_type'] as String,
      confidence: (sample['confidence'] as num).toDouble(),
      healthStatus: sample['health_status'] as String,
      diseaseName: sample['disease_name'] as String?,
      diseaseConfidence: (sample['disease_confidence'] as num).toDouble(),
      symptomsSeen: List<String>.from(sample['symptoms_seen'] as List),
      severity: sample['severity'] as int,
      likelyCauses: List<String>.from(sample['likely_causes'] as List),
      treatmentSteps: List<String>.from(sample['treatment_steps'] as List),
      preventionTips: List<String>.from(sample['prevention_tips'] as List),
      imageUrl: sample['image'] as String,
      timestamp: DateTime.now().toIso8601String(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiagnosisReportScreen(report: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Plant Scanner & Disease Detector',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: ResponsiveContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Viewfinder Scanner Box
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 380,
                  width: double.infinity,
                  color: Colors.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_selectedImageBytes != null)
                        Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.cover,
                        )
                      else
                        Image.network(
                          'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=800&auto=format&fit=crop',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade900,
                            child: const Center(
                              child: Icon(Icons.eco_rounded, color: AppColors.primaryLight, size: 64),
                            ),
                          ),
                        ),

                      // Dark vignette
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),

                      // Top Bar Status
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.circle, size: 8, color: AppColors.accentMint),
                                  SizedBox(width: 6),
                                  Text(
                                    'Gemini Vision 2.5 Flash',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Real Analysis Active',
                                style: TextStyle(color: AppColors.accentMint, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Laser Reticle Box
                      Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryLight.withOpacity(0.7),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              AnimatedBuilder(
                                animation: _laserAnim,
                                builder: (context, _) => Positioned(
                                  top: _laserAnim.value * 210,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryLight.withOpacity(0.9),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (_isAnalyzing)
                                const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(color: AppColors.primaryLight),
                                      SizedBox(height: 12),
                                      Text(
                                        'Analyzing Plant Pathogens...',
                                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Error Banner (if any)
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.urgent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.urgent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.urgent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.urgent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Camera & Upload Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : () => _pickAndAnalyzeImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing ? null : () => _pickAndAnalyzeImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Upload Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Optional Demo Samples Section (Clearly Labeled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🧪 DEMO SAMPLES (FOR OFFLINE PREVIEWS)',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Offline Only', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'These samples demonstrate the dossier result layout without requiring a live camera capture.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _demoSamples.map((sample) {
                        return ActionChip(
                          avatar: const Icon(Icons.science_outlined, size: 16),
                          label: Text(sample['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          onPressed: () => _loadDemoSample(sample),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
