import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/plant_guide.dart';
import '../services/mock_api_service.dart';
import '../widgets/empty_state_view.dart';

class PlantGuideScreen extends StatefulWidget {
  const PlantGuideScreen({super.key});

  @override
  State<PlantGuideScreen> createState() => _PlantGuideScreenState();
}

class _PlantGuideScreenState extends State<PlantGuideScreen> {
  List<PlantGuideItem> _guideItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Indoor',
    'Succulent',
    'Tropical',
    'Fern',
    'Flowering',
    'Tree',
  ];

  @override
  void initState() {
    super.initState();
    _fetchGuides();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchGuides() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await PlantApiService.fetchPlantGuides(
        query: _searchController.text,
        category: _selectedCategory,
      );
      setState(() {
        _guideItems = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load plant guides. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Botanical Care Guide',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reload Guide',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchGuides,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _fetchGuides(),
              decoration: InputDecoration(
                hintText: 'Search plant care encyclopedia...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  onPressed: _fetchGuides,
                ),
              ),
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                      _fetchGuides();
                    },
                    backgroundColor:
                        isDark ? AppColors.darkCard : AppColors.lightCard,
                    selectedColor: isDark
                        ? AppColors.primaryGreen.withOpacity(0.5)
                        : AppColors.accentSage,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? (isDark
                              ? AppColors.accentMint
                              : AppColors.primaryDark)
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Main Content with Loading / Error / Data States
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryGreen),
                        SizedBox(height: 16),
                        Text(
                          'Loading plant guides...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? EmptyStateView(
                        emoji: '⚠️',
                        title: 'Connection Issue',
                        message: _errorMessage!,
                        buttonText: 'Try Again',
                        onButtonPressed: _fetchGuides,
                      )
                    : _guideItems.isEmpty
                        ? EmptyStateView(
                            emoji: '🔍',
                            title: 'No Guide Matches',
                            message:
                                'No matching plant guide entries found. Try a different keyword.',
                            buttonText: 'Clear Search',
                            onButtonPressed: () {
                              _searchController.clear();
                              setState(() => _selectedCategory = 'All');
                              _fetchGuides();
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            itemCount: _guideItems.length,
                            itemBuilder: (context, index) {
                              final item = _guideItems[index];
                              return _buildGuideCard(context, item, isDark);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(
      BuildContext context, PlantGuideItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Emoji, Name, Difficulty
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.accentSage.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    item.iconEmoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.commonName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      item.scientificName,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.difficulty,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Summary text
          Text(
            item.careSummary,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Key Metrics Chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMetricChip(
                icon: Icons.wb_sunny_outlined,
                label: item.lightRequirement,
                isDark: isDark,
              ),
              _buildMetricChip(
                icon: Icons.water_drop_outlined,
                label: item.wateringFrequency,
                isDark: isDark,
              ),
              _buildMetricChip(
                icon: Icons.pets_outlined,
                label: item.toxicity,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pro Tips Expansion
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text(
                '💡 Pro Care Tips & Guidance',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.terracotta,
                ),
              ),
              children: item.proTips.map((tip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen)),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.primaryDark),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
