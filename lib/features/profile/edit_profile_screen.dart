import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/providers/profile_provider.dart';
import 'package:sevent_eps/providers/auth_provider.dart';
import 'package:sevent_eps/features/profile/photo_upload_widget.dart';
import 'package:sevent_eps/features/profile/interests_selector.dart';
import 'package:sevent_eps/models/profile.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;

  const EditProfileScreen({
    super.key,
    this.isOnboarding = false,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();

  List<String> _selectedInterests = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Check if profile is already complete, redirect to home if onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileAndRedirect();
    });
    _loadExistingProfile();
  }

  void _checkProfileAndRedirect() {
    final profile = ref.read(currentProfileProvider);
    if (widget.isOnboarding && profile != null && profile.isComplete) {
      // Profile already complete, go to home
      context.go('/');
    }
  }

  void _loadExistingProfile() {
    final profile = ref.read(currentProfileProvider);
    if (profile != null) {
      _nameController.text = profile!.name;
      _ageController.text = profile!.age.toString();
      _bioController.text = profile!.bio ?? '';
      _cityController.text = profile!.city ?? '';
      _selectedInterests = List.from(profile!.interests ?? []);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(profileProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text),
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            interests: _selectedInterests.isEmpty ? null : _selectedInterests,
            city: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            university: null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: AppTheme.sageGreen,
          ),
        );

        // If onboarding, go to home; otherwise go back
        if (widget.isOnboarding) {
          context.go('/');
        } else {
          context.pop();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOnboarding ? 'Create Profile' : 'Edit Profile'),
        leading: widget.isOnboarding
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
      ),
      body: profileAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error Message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Progress Indicator
                    if (widget.isOnboarding)
                      _buildProgressBar(profile),

                    const SizedBox(height: 24),

                    // Photo Upload Section
                    PhotoUploadWidget(
                      photos: profile?.photos ?? [],
                      onPhotoUploaded: () {
                        ref.read(profileProvider.notifier).refresh();
                      },
                      onPhotoDeleted: (photoId) async {
                        await ref.read(profileProvider.notifier).deletePhoto(photoId);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        hintText: 'Your name',
                        prefixIcon: Icon(Icons.person_outlined),
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
                    const SizedBox(height: 16),

                    // Age Field
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age *',
                        hintText: 'Your age',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        final age = int.tryParse(value);
                        if (age == null) {
                          return 'Please enter a valid number';
                        }
                        if (age < 18) {
                          return 'You must be at least 18 years old';
                        }
                        if (age > 120) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // City Field
                    TextFormField(
                      controller: _cityController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'City *',
                        hintText: 'Your city',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bio Field
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'About Me',
                        hintText: 'Tell others about yourself...',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Interests Selection
                    InterestsSelector(
                      selectedInterests: _selectedInterests,
                      onInterestsChanged: (interests) {
                        setState(() {
                          _selectedInterests = interests;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(widget.isOnboarding ? 'Continue' : 'Save Profile'),
                    ),

                    if (widget.isOnboarding) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Skip for now'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProgressBar(Profile? profile) {
    final completion = profile?.completionPercentage ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completion',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '$completion%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.terracotta,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: completion / 100,
          backgroundColor: AppTheme.charcoal.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.terracotta),
        ),
      ],
    );
  }
}
