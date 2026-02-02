import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/providers/onboarding_provider.dart';

/// Preferences step (Step 9)
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

  final List<double> _ageOptions = [18, 25, 30, 40, 50, 60, 70, 80, 90, 100];
  double _minAge = 18;
  double _maxAge = 100;

  final List<double> _distanceOptions = [10, 25, 50, 75, 100, 150, 200];
  double _selectedDistance = 50;

  Future<void> _submit() async {
    try {
      await ref.read(onboardingProvider.notifier).saveStep(9, {
        'gender_interest': _selectedGender.toLowerCase(),
        'age_min': _minAge.toInt(),
        'age_max': _maxAge.toInt(),
        'distance_radius': _selectedDistance.toInt(),
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
                              'Min',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.charcoal.withOpacity(0.7),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.charcoal.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<int>(
                                value: _minAge.toInt(),
                                isExpanded: true,
                                underline: const SizedBox.shrink(),
                                items: _ageOptions
                                    .where((age) => age <= _maxAge)
                                    .map((age) {
                                  return DropdownMenuItem<int>(
                                    value: age.toInt(),
                                    child: Text('$age'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      if (value > _maxAge) _maxAge = value.toDouble();
                                      _minAge = value.toDouble();
                                    });
                                  }
                                },
                              ),
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
                              'Max',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.charcoal.withOpacity(0.7),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.charcoal.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<int>(
                                value: _maxAge.toInt(),
                                isExpanded: true,
                                underline: const SizedBox.shrink(),
                                items: _ageOptions
                                    .where((age) => age >= _minAge)
                                    .map((age) {
                                  return DropdownMenuItem<int>(
                                    value: age.toInt(),
                                    child: Text('$age'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      if (value < _minAge) _minAge = value.toDouble();
                                      _maxAge = value.toDouble();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                  _buildSectionTitle('Distance'),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Slider(
                        value: _selectedDistance,
                        min: 10,
                        max: 200,
                        divisions: 6,
                        activeColor: AppTheme.terracotta,
                        onChanged: (value) {
                          setState(() {
                            _selectedDistance = value;
                          });
                        },
                      ),
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
