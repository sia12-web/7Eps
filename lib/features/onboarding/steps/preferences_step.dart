import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/providers/onboarding_provider.dart';

/// Preferences step (Step 8)
/// Set dating preferences: gender interest, age range, distance
class PreferencesStep extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const PreferencesStep({
    super.key,
    required this.onContinue,
    this.onBack,
  });

  @override
  ConsumerState<PreferencesStep> createState() => _PreferencesStepState();
}

class _PreferencesStepState extends ConsumerState<PreferencesStep> {
  static const List<String> _genderOptions = ['Men', 'Women', 'Everyone'];
  String _selectedGender = 'Everyone';

  double _minAge = 18;
  double _maxAge = 100;
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();

  double _selectedDistance = 50;
  final TextEditingController _distanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAgeRange();
    // Initialize distance controller
    _distanceController.text = _selectedDistance.toInt().toString();
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _initializeAgeRange() {
    // Get onboarding data to find user's DOB
    final onboardingAsync = ref.read(onboardingProvider);
    final onboardingData = onboardingAsync.value;

    if (onboardingData != null) {
      final dobString = onboardingData.getData<String>('dob');
      if (dobString != null) {
        try {
          final dob = DateTime.parse(dobString);
          final userAge = _calculateAge(dob);

          // Set max age to user's age + 10, capped at 100
          final defaultMaxAge = (userAge + 10).clamp(18, 100);
          _maxAge = defaultMaxAge.toDouble();

          // Set min age to be reasonable (user's age - 10, min 18)
          _minAge = (userAge - 10).clamp(18, userAge).toDouble();

          // Initialize controllers
          _minAgeController.text = _minAge.toInt().toString();
          _maxAgeController.text = _maxAge.toInt().toString();
        } catch (e) {
          // If parsing fails, use defaults
          _maxAge = 100;
          _minAge = 18;
          _minAgeController.text = '18';
          _maxAgeController.text = '100';
        }
      } else {
        // No DOB found, use defaults
        _maxAge = 100;
        _minAge = 18;
        _minAgeController.text = '18';
        _maxAgeController.text = '100';
      }
    } else {
      // No onboarding data, use defaults
      _maxAge = 100;
      _minAge = 18;
      _minAgeController.text = '18';
      _maxAgeController.text = '100';
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    // Adjust if birthday hasn't occurred yet this year
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Future<void> _submit() async {
    try {
      // Parse values from controllers to ensure we use the latest input
      final minAge = int.tryParse(_minAgeController.text) ?? _minAge.toInt();
      final maxAge = int.tryParse(_maxAgeController.text) ?? _maxAge.toInt();
      final distance = int.tryParse(_distanceController.text) ?? _selectedDistance.toInt();

      // Validate ranges
      if (minAge < 18 || minAge > 100 || maxAge < 18 || maxAge > 100) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Age must be between 18 and 100')),
          );
        }
        return;
      }

      if (minAge > maxAge) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Minimum age cannot be greater than maximum age')),
          );
        }
        return;
      }

      if (distance < 10 || distance > 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Distance must be between 10 and 200 km')),
          );
        }
        return;
      }

      await ref.read(onboardingProvider.notifier).saveStep(8, {
        'gender_interest': _selectedGender.toLowerCase(),
        'age_min': minAge,
        'age_max': maxAge,
        'distance_radius': distance,
      });

      widget.onContinue();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            if (widget.onBack != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Your Preferences',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.charcoal,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Help us find compatible matches for you',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.7),
                          ),
                    ),

                    const SizedBox(height: 32),

                    // Interested In
                    _buildSectionTitle('Interested In'),
                    const SizedBox(height: 12),
                    Row(
                      children: _genderOptions.map((gender) {
                        final isSelected = _selectedGender == gender;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGender = gender;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.sageGreen
                                      : AppTheme.charcoal.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.sageGreen
                                        : AppTheme.charcoal.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  gender,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.charcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom section with age range, distance, and continue
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Age Range
                  _buildSectionTitle('Age Range'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Min Age (18-100)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.charcoal.withOpacity(0.7),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _minAgeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '18',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppTheme.charcoal.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.sageGreen,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              onChanged: (value) {
                                final age = int.tryParse(value);
                                if (age != null && age >= 18 && age <= 100) {
                                  setState(() {
                                    _minAge = age.toDouble();
                                    if (_minAge > _maxAge) {
                                      _maxAge = _minAge;
                                      _maxAgeController.text = _maxAge.toInt().toString();
                                    }
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Max Age (18-100)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.charcoal.withOpacity(0.7),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _maxAgeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '100',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppTheme.charcoal.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.sageGreen,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              onChanged: (value) {
                                final age = int.tryParse(value);
                                if (age != null && age >= 18 && age <= 100) {
                                  setState(() {
                                    _maxAge = age.toDouble();
                                    if (_maxAge < _minAge) {
                                      _minAge = _maxAge;
                                      _minAgeController.text = _minAge.toInt().toString();
                                    }
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ages ${_minAge.toInt()} - ${_maxAge.toInt()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.sageGreen,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Distance Radius
                  _buildSectionTitle('Distance (km)'),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      // Continuous slider for visual feedback
                      Slider(
                        value: _selectedDistance,
                        min: 10,
                        max: 200,
                        divisions: 190, // Every 1 km (200 - 10 = 190 steps)
                        activeColor: AppTheme.terracotta,
                        onChanged: (value) {
                          setState(() {
                            _selectedDistance = value;
                            _distanceController.text = value.toInt().toString();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Text field for precise input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _distanceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '50',
                                labelText: 'Distance in kilometers',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppTheme.charcoal.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.sageGreen,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                suffixText: 'km',
                              ),
                              onChanged: (value) {
                                final distance = int.tryParse(value);
                                if (distance != null && distance >= 10 && distance <= 200) {
                                  setState(() {
                                    _selectedDistance = distance.toDouble();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Within ${_selectedDistance.toInt()} km',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.sageGreen,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.terracotta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.charcoal.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
