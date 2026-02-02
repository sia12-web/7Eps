import 'package:flutter/material.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';

/// Age verification gate (Step 4)
/// Hard stop for users under 18
class AgeGateStep extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const AgeGateStep({
    super.key,
    required this.onContinue,
    this.onBack,
  });

  @override
  State<AgeGateStep> createState() => _AgeGateStepState();
}

class _AgeGateStepState extends State<AgeGateStep> {
  DateTime? _selectedDate;
  bool _checkboxConfirmed = false;
  String? _errorMessage;

  // Month options
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Default to a reasonable date (year 2000)
  int _selectedMonth = 0;
  int _selectedDay = 1;
  int _selectedYear = 2000;

  @override
  void initState() {
    super.initState();
    _updateSelectedDate();
  }

  void _updateSelectedDate() {
    try {
      _selectedDate = DateTime(_selectedYear, _selectedMonth + 1, _selectedDay);
      _errorMessage = null;
    } catch (e) {
      _selectedDate = null;
    }
    setState(() {});
  }

  int _calculateAge(DateTime? dob) {
    if (dob == null) return 0;

    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  bool _isValidAge() {
    if (_selectedDate == null || !_checkboxConfirmed) {
      return false;
    }
    return _calculateAge(_selectedDate) >= 18;
  }

  void _handleContinue() {
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Please select a valid date of birth';
      });
      return;
    }

    if (!_checkboxConfirmed) {
      setState(() {
        _errorMessage = 'Please confirm you are 18 years or older';
      });
      return;
    }

    final age = _calculateAge(_selectedDate);

    if (age < 18) {
      // Hard block - under 18
      _showUnder18Dialog();
    } else {
      // Proceed
      widget.onContinue();
    }
  }

  void _showUnder18Dialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Age Requirement'),
        content: const Text(
          '7Eps is only for users 18 years or older. We are unable to proceed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Sign out and redirect to auth
              // For now, just show error
              setState(() {
                _errorMessage = 'You must be 18+ to use 7Eps';
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = _calculateAge(_selectedDate);
    final isValid = _isValidAge();

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.terracotta.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cake,
                        size: 56,
                        color: AppTheme.terracotta,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Verify Your Age',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.charcoal,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      '7Eps is for adults 18+. Please confirm your age to continue.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.7),
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Date picker
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.charcoal.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Month dropdown
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Month',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.charcoal.withOpacity(0.7),
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppTheme.charcoal.withOpacity(0.2),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _selectedMonth,
                                          isExpanded: true,
                                          items: List.generate(_months.length, (index) {
                                            return DropdownMenuItem<int>(
                                              value: index,
                                              child: Text(_months[index]),
                                            );
                                          }),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                _selectedMonth = value;
                                                _updateSelectedDate();
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Day dropdown
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Day',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.charcoal.withOpacity(0.7),
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppTheme.charcoal.withOpacity(0.2),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _selectedDay,
                                          isExpanded: true,
                                          items: List.generate(31, (index) {
                                            return DropdownMenuItem<int>(
                                              value: index + 1,
                                              child: Text('${index + 1}'),
                                            );
                                          }),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                _selectedDay = value;
                                                _updateSelectedDate();
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Year dropdown
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Year',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.charcoal.withOpacity(0.7),
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppTheme.charcoal.withOpacity(0.2),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _selectedYear,
                                          isExpanded: true,
                                          items: List.generate(100, (index) {
                                            final year = DateTime.now().year - index;
                                            return DropdownMenuItem<int>(
                                              value: year,
                                              child: Text('$year'),
                                            );
                                          }),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                _selectedYear = value;
                                                _updateSelectedDate();
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Age display
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: age >= 18
                                  ? AppTheme.sageGreen.withOpacity(0.1)
                                  : AppTheme.terracotta.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  age >= 18 ? Icons.check_circle : Icons.info_outline,
                                  color: age >= 18 ? AppTheme.sageGreen : AppTheme.terracotta,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    age > 0
                                        ? 'You are $age years old'
                                        : 'Select your date of birth',
                                    style: TextStyle(
                                      color: age >= 18 ? AppTheme.sageGreen : AppTheme.terracotta,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Checkbox confirmation
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.charcoal.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _checkboxConfirmed,
                            onChanged: (value) {
                              setState(() {
                                _checkboxConfirmed = value ?? false;
                                if (_errorMessage != null) {
                                  _errorMessage = null;
                                }
                              });
                            },
                            activeColor: AppTheme.sageGreen,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _checkboxConfirmed = !_checkboxConfirmed;
                                  if (_errorMessage != null) {
                                    _errorMessage = null;
                                  }
                                });
                              },
                              child: Text(
                                'I confirm I am 18 years or older',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.terracotta,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid ? _handleContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.terracotta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: AppTheme.terracotta.withOpacity(0.5),
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

                    const SizedBox(height: 24),

                    // Privacy note
                    Text(
                      'Your date of birth is used only for age verification and will not be shared.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.5),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
