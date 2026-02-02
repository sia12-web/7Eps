import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/interests.dart';
import 'package:sevent_eps/providers/onboarding_provider.dart';

/// Interests step (Step 7)
/// Select 5-12 interests from curated list
class InterestsStep extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const InterestsStep({
    super.key,
    required this.onContinue,
    this.onBack,
  });

  @override
  ConsumerState<InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends ConsumerState<InterestsStep> {
  final Set<String> _selectedInterests = {};
  String _customInterest = '';
  final TextEditingController _customController = TextEditingController();
  String? _errorMessage;

  static const int _minInterests = 5;
  static const int _maxInterests = 12;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool get _isValid => _selectedInterests.length >= _minInterests;

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        if (_selectedInterests.length < _maxInterests) {
          _selectedInterests.add(interest);
        }
      }
      if (_errorMessage != null) {
        _errorMessage = null;
      }
    });
  }

  void _addCustomInterest() {
    final trimmed = _customController.text.trim();
    if (trimmed.isEmpty) return;

    if (trimmed.length > 20) {
      setState(() {
        _errorMessage = 'Interest must be 20 characters or less';
      });
      return;
    }

    if (_selectedInterests.length >= _maxInterests) {
      setState(() {
        _errorMessage = 'Maximum $_maxInterests interests selected';
      });
      return;
    }

    setState(() {
      _selectedInterests.add(trimmed);
      _customController.clear();
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (!_isValid) {
      setState(() {
        _errorMessage = 'Please select at least $_minInterests interests';
      });
      return;
    }

    try {
      // Save interests
      await ref.read(onboardingProvider.notifier).saveStep(7, {
        'interests': _selectedInterests.toList(),
      });

      widget.onContinue();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _selectedInterests.length;
    final isMax = count >= _maxInterests;

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
                      'Your Interests',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.charcoal,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Select $_minInterests-$_maxInterests interests that describe you',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.7),
                          ),
                    ),

                    const SizedBox(height: 24),

                    // Counter display
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: count >= _minInterests
                            ? AppTheme.sageGreen.withOpacity(0.1)
                            : AppTheme.charcoal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: count >= _minInterests
                              ? AppTheme.sageGreen
                              : AppTheme.charcoal.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            count >= _minInterests
                                ? Icons.check_circle
                                : Icons.info_outline,
                            color: count >= _minInterests
                                ? AppTheme.sageGreen
                                : AppTheme.charcoal.withOpacity(0.5),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              count >= _minInterests
                                  ? isMax
                                      ? 'Perfect! $_maxInterests interests selected'
                                      : 'Great! $count/$_maxInterests selected'
                                  : 'Select $_minInterests more to continue',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: count >= _minInterests
                                        ? AppTheme.sageGreen
                                        : AppTheme.charcoal.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Category tabs and interests
                    ...interestCategories.entries.map((entry) {
                      return _buildCategory(entry.key, entry.value);
                    }),

                    const SizedBox(height: 32),

                    // Custom interest input
                    Text(
                      'Add your own',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customController,
                            enabled: !isMax,
                            maxLength: 20,
                            decoration: InputDecoration(
                              hintText: 'E.g., Pottery',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.charcoal.withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.sageGreen,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onSubmitted: (_) => _addCustomInterest(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: isMax ? null : _addCustomInterest,
                          icon: const Icon(Icons.add_circle),
                          color: AppTheme.sageGreen,
                          iconSize: 32,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.terracotta.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppTheme.terracotta,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    if (_errorMessage != null) const SizedBox(height: 16),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isValid ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.terracotta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: AppTheme.terracotta.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isValid ? 'Continue' : 'Select $_minInterests interests',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String category, List<String> interests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.charcoal.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: interests.map<Widget>((interest) {
            final isSelected = _selectedInterests.contains(interest);
            final isDisabled = !isSelected && _selectedInterests.length >= _maxInterests;

            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: isDisabled ? null : (_) => _toggleInterest(interest),
              selectedColor: AppTheme.sageGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.charcoal,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: isSelected
                  ? AppTheme.sageGreen
                  : AppTheme.charcoal.withOpacity(0.1),
              side: BorderSide(
                color: isSelected ? AppTheme.sageGreen : Colors.transparent,
              ),
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
