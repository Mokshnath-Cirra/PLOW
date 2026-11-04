import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DiagnosisReportScreen extends StatelessWidget {
  final String specimenKey;

  const DiagnosisReportScreen({super.key, this.specimenKey = 'early_blight'});

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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: AppColors.primaryLight),
              SizedBox(width: 6),
              Text(
                'VERIFIED 94.2% AI CONFIDENCE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs
                const Text(
                  'Organic Tomato • Greenhouse B (Plot 4B) • #AB-8942',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Pathological ID Hero Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: AppColors.darkSurface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Leaf Image with bounding box
                        Stack(
                          children: [
                            Container(
                              height: 220,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=800&auto=format&fit=crop',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.urgent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'STAGE 2: MODERATE SEVERITY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Target Box
                            Positioned(
                              top: 50,
                              left: 80,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.primaryLight, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text(
                                      'Target: 96%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        backgroundColor: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Disease Details Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PATHOLOGICAL ID • Solanaceae Family',
                                style: TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Early Blight',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Text(
                                'Alternaria solani [Sorauer]',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Metadata Grid
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildMetaCol(
                                      'Classification', 'Ascomycete Fungal'),
                                  _buildMetaCol('Timestamp', 'Today 09:14 Live'),
                                  _buildMetaCol(
                                      'Microclimate', '78% RH • 26.5°C'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Severity Risk Matrix Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '● HIGH ALERT',
                              style: TextStyle(
                                color: AppColors.urgent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: const TextSpan(
                                text: '64',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' / 100',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Accelerating tissue loss; containment priority high before defoliation spreads.',
                              style: TextStyle(fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.urgent, width: 6),
                        ),
                        child: const Center(
                          child: Text(
                            'INDEX',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progression Wave (Timeline from Screenshot)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Text('🌊', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Text(
                                'Progression Wave',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Active Phase 2',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildTimelineStep(
                        'Day 1–3: Spore Germination',
                        'Microscopic stomatal penetration during warm wet night cycle.',
                        isResolved: true,
                      ),
                      _buildTimelineStep(
                        'Day 4–7: Bullseye Target Spots',
                        'Concentric ring necrosis with intense yellow chloroplast halo. High spore production underway.',
                        isActive: true,
                      ),
                      _buildTimelineStep(
                        'Day 8–12: Foliar Blight & Defoliation',
                        'Complete leaflet yellowing, desiccation, and premature drop causing sun scald risk.',
                        isPending: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Etiology & Vectors
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🔬 Etiology & Vectors',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildVectorBox(
                        '💧 Primary Inoculum Trigger',
                        'Overhead drip splash and persistent leaf wetness > 4.5 hours in poorly ventilated canopy rows.',
                      ),
                      const SizedBox(height: 8),
                      _buildVectorBox(
                        '🌡️ Thermal Optimum',
                        'Conidiophores sporulate rapidly between 24°C and 29°C with alternating wet-dry microcycles.',
                      ),
                      const SizedBox(height: 8),
                      _buildVectorBox(
                        '🎯 Distinctive Diagnostic Marker',
                        'Alternaria acid secretion creates toxic dark concentric rings and outer golden-yellow chloroplast margin.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Plan Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prescription & Spray Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Organic OMRI-listed fungicides ready →',
                            style: TextStyle(
                              color: AppColors.accentMint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '⏰ Added 7-Day Liquid Copper spray reminder!'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Set Reminder'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaCol(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep(
    String title,
    String desc, {
    bool isResolved = false,
    bool isActive = false,
    bool isPending = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isResolved
                  ? Colors.green.shade100
                  : (isActive ? Colors.red.shade100 : Colors.grey.shade200),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isResolved ? Icons.check : (isActive ? Icons.circle : Icons.schedule),
              size: 14,
              color: isResolved
                  ? Colors.green
                  : (isActive ? Colors.red : Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isActive ? Colors.red : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVectorBox(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
