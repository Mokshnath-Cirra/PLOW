import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AddEditPlantScreen extends StatefulWidget {
  final Plant? plantToEdit;

  const AddEditPlantScreen({super.key, this.plantToEdit});

  @override
  State<AddEditPlantScreen> createState() => _AddEditPlantScreenState();
}

class _AddEditPlantScreenState extends State<AddEditPlantScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _species;
  late String _location;
  late String _category;
  late double _waterInterval;
  late double _mistInterval;
  late SunlightLevel _sunlight;
  late String _notes;
  late String _selectedEmoji;
  late DateTime _lastWatered;

  final List<String> _locationOptions = [
    'Living Room',
    'Bedroom',
    'Balcony',
    'Office / Study',
    'Kitchen',
    'Bathroom',
    'Garden',
  ];

  final List<String> _categoryOptions = [
    'Indoor',
    'Succulent',
    'Tropical',
    'Fern',
    'Flowering',
    'Herb / Edible',
    'Tree',
    'Vine',
  ];

  final List<String> _emojiOptions = [
    '🌿',
    '🪴',
    '🌵',
    '🌱',
    '🌴',
    '🪷',
    '🌸',
    '🌳',
    '🍃',
    '🌾',
    '🎋',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.plantToEdit;
    if (p != null) {
      _name = p.name;
      _species = p.species;
      _location = p.location;
      _category = p.category;
      _waterInterval = p.waterIntervalDays.toDouble();
      _mistInterval = p.mistIntervalDays.toDouble();
      _sunlight = p.sunlight;
      _notes = p.notes;
      _selectedEmoji = p.emojiAvatar;
      _lastWatered = p.lastWatered;
    } else {
      _name = '';
      _species = '';
      _location = 'Living Room';
      _category = 'Indoor';
      _waterInterval = 7.0;
      _mistInterval = 3.0;
      _sunlight = SunlightLevel.indirectBright;
      _notes = '';
      _selectedEmoji = '🌿';
      _lastWatered = DateTime.now();
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = context.read<PlantProvider>();

      if (widget.plantToEdit != null) {
        // Edit existing plant
        final updated = widget.plantToEdit!.copyWith(
          name: _name,
          species: _species,
          location: _location,
          category: _category,
          waterIntervalDays: _waterInterval.round(),
          mistIntervalDays: _mistInterval.round(),
          sunlight: _sunlight,
          notes: _notes,
          emojiAvatar: _selectedEmoji,
          lastWatered: _lastWatered,
        );
        provider.updatePlant(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated "${_name}" successfully!'),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Create new plant
        final newPlant = Plant(
          id: 'plant_${DateTime.now().millisecondsSinceEpoch}',
          name: _name,
          species: _species,
          location: _location,
          category: _category,
          waterIntervalDays: _waterInterval.round(),
          mistIntervalDays: _mistInterval.round(),
          sunlight: _sunlight,
          notes: _notes,
          emojiAvatar: _selectedEmoji,
          lastWatered: _lastWatered,
          logs: [
            CareLog(
              id: 'init_log_${DateTime.now().millisecondsSinceEpoch}',
              type: CareType.water,
              timestamp: _lastWatered,
              note: 'Plant registered in garden',
            ),
          ],
        );
        provider.addPlant(newPlant);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${_name}" to your plant garden!'),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.plantToEdit != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Plant Details' : 'Add New Plant',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji Avatar Selector
                  Text(
                    'Choose Plant Icon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _emojiOptions.map((emoji) {
                        final isSelected = _selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedEmoji = emoji),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGreen.withOpacity(0.2)
                                  : (isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Plant Nickname
                  CustomTextField(
                    label: 'Plant Nickname *',
                    hintText: 'e.g. Monty, Greenie, Sprout',
                    prefixIcon: Icons.badge_outlined,
                    initialValue: _name,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please provide a name or nickname for your plant';
                      }
                      return null;
                    },
                    onSaved: (val) => _name = val!.trim(),
                  ),
                  const SizedBox(height: 18),

                  // Plant Species
                  CustomTextField(
                    label: 'Botanical / Species Name *',
                    hintText: 'e.g. Monstera Deliciosa, Epipremnum aureum',
                    prefixIcon: Icons.eco_outlined,
                    initialValue: _species,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please specify the plant species or type';
                      }
                      return null;
                    },
                    onSaved: (val) => _species = val!.trim(),
                  ),
                  const SizedBox(height: 18),

                  // Location Dropdown & Category Dropdown
                  Row(
                    children: [
                      // Location Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Room / Location',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _locationOptions.contains(_location)
                                  ? _location
                                  : _locationOptions.first,
                              decoration: const InputDecoration(),
                              items: _locationOptions
                                  .map((loc) => DropdownMenuItem(
                                        value: loc,
                                        child: Text(loc,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _location = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Category Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plant Category',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _categoryOptions.contains(_category)
                                  ? _category
                                  : _categoryOptions.first,
                              decoration: const InputDecoration(),
                              items: _categoryOptions
                                  .map((cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _category = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Watering Frequency Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Watering Frequency',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Every ${_waterInterval.round()} days',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.waterBlue,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _waterInterval,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    activeColor: AppColors.waterBlue,
                    label: '${_waterInterval.round()} days',
                    onChanged: (val) => setState(() => _waterInterval = val),
                  ),
                  const SizedBox(height: 16),

                  // Misting Frequency Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Misting Frequency (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        _mistInterval.round() == 0
                            ? 'Disabled'
                            : 'Every ${_mistInterval.round()} days',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mistCyan,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _mistInterval,
                    min: 0,
                    max: 14,
                    divisions: 14,
                    activeColor: AppColors.mistCyan,
                    label: _mistInterval.round() == 0
                        ? 'Disabled'
                        : '${_mistInterval.round()} days',
                    onChanged: (val) => setState(() => _mistInterval = val),
                  ),
                  const SizedBox(height: 20),

                  // Sunlight Requirement Selector
                  Text(
                    'Sunlight Exposure',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: SunlightLevel.values.map((level) {
                      final isSelected = _sunlight == level;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _sunlight = level),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.sunYellow.withOpacity(0.2)
                                  : (isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.sunYellow
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.wb_sunny_rounded,
                                  size: 20,
                                  color: isSelected
                                      ? AppColors.terracotta
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  level.displayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? (isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.primaryDark)
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Last Watered Date Picker
                  Text(
                    'Last Watered On',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _lastWatered,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 90)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _lastWatered = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 18, color: AppColors.primaryGreen),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, MMM d, yyyy')
                                .format(_lastWatered),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Care Notes
                  CustomTextField(
                    label: 'Care Notes & Soil Specifications',
                    hintText:
                        'e.g. Well-draining perlite mix, loves gentle misting, keep out of AC draft...',
                    initialValue: _notes,
                    maxLines: 3,
                    onSaved: (val) => _notes = val ?? '',
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: isEditing ? 'Save Changes' : 'Add Plant to Garden',
                    icon: Icons.check_rounded,
                    width: double.infinity,
                    onPressed: _saveForm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
