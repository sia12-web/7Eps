import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/providers/onboarding_provider.dart';

/// Basics step (Step 6)
/// Collect core identity information: name, pronouns, city, university, headline
class BasicsStep extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const BasicsStep({
    super.key,
    required this.onContinue,
    this.onBack,
  });

  @override
  ConsumerState<BasicsStep> createState() => _BasicsStepState();
}

class _BasicsStepState extends ConsumerState<BasicsStep> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _universityController = TextEditingController();
  final _headlineController = TextEditingController();

  String? _selectedPronouns;
  String? _errorMessage;

  static const List<String> _pronounOptions = [
    'He/Him',
    'She/Her',
    'They/Them',
    'Custom',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _universityController.dispose();
    _headlineController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _nameController.text.trim().length >= 2 &&
        _cityController.text.trim().length >= 2;
  }

  Future<void> _submit() async {
    if (!_isValid) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      // Collect form data
      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'city': _cityController.text.trim(),
        if (_universityController.text.trim().isNotEmpty)
          'university': _universityController.text.trim(),
        if (_selectedPronouns != null) 'pronouns': _selectedPronouns,
        if (_headlineController.text.trim().isNotEmpty)
          'headline': _headlineController.text.trim(),
      };

      // Save step
      await ref.read(onboardingProvider.notifier).saveStep(6, data);

      widget.onContinue();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'Tell Us About Yourself',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.charcoal,
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Let\'s start with the basics',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.charcoal.withOpacity(0.7),
                            ),
                      ),

                      const SizedBox(height: 32),

                      // First Name (Required)
                      _buildSectionTitle('First Name *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _buildInputDecoration(
                          'Enter your first name',
                          Icons.person,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Pronouns (Optional)
                      _buildSectionTitle('Pronouns (optional)'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPronouns,
                        decoration: _buildInputDecoration(
                          'Select your pronouns',
                          Icons.badge,
                        ),
                        items: _pronounOptions.map((pronouns) {
                          return DropdownMenuItem<String>(
                            value: pronouns,
                            child: Text(pronouns),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPronouns = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // City (Required)
                      _buildSectionTitle('City *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cityController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _buildInputDecoration(
                          'Enter your city',
                          Icons.location_city,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your city';
                          }
                          if (value.trim().length < 2) {
                            return 'City must be at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // University/Campus (Optional)
                      _buildSectionTitle('University/Campus (optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _universityController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _buildInputDecoration(
                          'Enter your university or campus',
                          Icons.school,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Headline (Optional)
                      _buildSectionTitle('Headline (optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _headlineController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 100,
                        textInputAction: TextInputAction.done,
                        decoration: _buildInputDecoration(
                          'Your vibe in 10 words or less',
                          Icons.format_quote,
                        ).copyWith(
                          helperText: 'e.g., "Coffee addict seeking museum buddy"',
                        ),
                        onFieldSubmitted: (_) => _submit(),
                      ),

                      if (_headlineController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${_headlineController.text.length}/100',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.charcoal.withOpacity(0.5),
                                ),
                          ),
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

                      // Note
                      Center(
                        child: Text(
                          '* Required fields',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.charcoal.withOpacity(0.5),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.charcoal.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
