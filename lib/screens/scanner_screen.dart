import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'diagnosis_report_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserAnim;
  String _selectedMode = 'natural';
  String _selectedSpecimen = 'early_blight';

  final Map<String, Map<String, dynamic>> _specimens = {
    'early_blight': {
      'crop': 'Tomato • GH-B (Organic)',
      'disease': 'Early Blight (Alternaria solani)',
      'confidence': '94.2%',
      'image':
          'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=800&auto=format&fit=crop',
    },
    'powdery_mildew': {
      'crop': 'Rose • Garden Bed A',
      'disease': 'Powdery Mildew (Podosphaera)',
      'confidence': '96.8%',
      'image':
          'https://images.unsplash.com/photo-1550950158-d0d960dff51b?w=800&auto=format&fit=crop',
    },
    'yellowing_leaf': {
      'crop': 'Monstera • Living Room',
      'disease': 'Nutrient & Drainage Stress',
      'confidence': '91.4%',
      'image':
          'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=800&auto=format&fit=crop',
    },
  };

  @override
  void initState() {
    super.initState();
    _laserAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserAnim.dispose();
    super.dispose();
  }

  void _runDiagnosis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiagnosisReportScreen(specimenKey: _selectedSpecimen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final specimen = _specimens[_selectedSpecimen]!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Phytosanitary Scanner',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Camera Viewfinder Box
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 380,
                    width: double.infinity,
                    color: Colors.black,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image preview
                        Image.network(
                          specimen['image'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade900,
                            child: const Center(
                              child: Icon(Icons.eco, color: Colors.green, size: 64),
                            ),
                          ),
                        ),

                        // Top HUD Info Pill
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Text(
                                  '🍅 ${specimen['crop']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Spectral 4K',
                                  style: TextStyle(
                                    color: AppColors.accentMint,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Reticle Center Box with pulsing Laser
                        Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primaryLight.withOpacity(0.8),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                // Animated Laser Line
                                AnimatedBuilder(
                                  animation: _laserAnim,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: _laserAnim.value * 190,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryLight
                                                  .withOpacity(0.8),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // AI Detection Result Pill
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primaryLight),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle,
                                    size: 16, color: AppColors.primaryLight),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${specimen['disease']} • ${specimen['confidence']} Conf.',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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

                // Spectral Mode Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeChip('RGB Natural', 'natural'),
                    const SizedBox(width: 8),
                    _buildModeChip('NDVI Sim', 'ndvi'),
                    const SizedBox(width: 8),
                    _buildModeChip('Thermal Stress', 'thermal'),
                  ],
                ),
                const SizedBox(height: 20),

                // Shutter Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library_outlined, size: 28),
                      onPressed: () {},
                    ),
                    GestureDetector(
                      onTap: _runDiagnosis,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🌿', style: TextStyle(fontSize: 30)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.auto_awesome_rounded,
                          size: 28, color: AppColors.primaryGreen),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Specimen Selector
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🧪 LOAD TEST SPECIMEN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('🍅 Early Blight'),
                            selected: _selectedSpecimen == 'early_blight',
                            onSelected: (_) => setState(
                                () => _selectedSpecimen = 'early_blight'),
                          ),
                          ChoiceChip(
                            label: const Text('🌸 Powdery Mildew'),
                            selected: _selectedSpecimen == 'powdery_mildew',
                            onSelected: (_) => setState(
                                () => _selectedSpecimen = 'powdery_mildew'),
                          ),
                          ChoiceChip(
                            label: const Text('🪴 Monstera Stress'),
                            selected: _selectedSpecimen == 'yellowing_leaf',
                            onSelected: (_) => setState(
                                () => _selectedSpecimen = 'yellowing_leaf'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip(String label, String modeKey) {
    final isSelected = _selectedMode == modeKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedMode = modeKey),
      selectedColor: AppColors.primaryDark,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : AppColors.primaryDark,
      ),
    );
  }
}
