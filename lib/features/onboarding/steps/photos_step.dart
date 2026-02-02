import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/profile_photo.dart';
import 'package:sevent_eps/providers/onboarding_provider.dart';
import 'package:sevent_eps/providers/profile_provider.dart';

/// Photos step (Step 8)
/// Upload 1-3 photos with blur preview showing Episode 1 appearance
class PhotosStep extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const PhotosStep({
    super.key,
    required this.onContinue,
    this.onBack,
  });

  @override
  ConsumerState<PhotosStep> createState() => _PhotosStepState();
}

class _PhotosStepState extends ConsumerState<PhotosStep> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;
  String? _errorMessage;

  static const int _minPhotos = 1;
  static const int _maxPhotos = 3;

  @override
  void dispose() {
    // Clean up temporary files only on non-web platforms
    if (!kIsWeb) {
      for (final image in _selectedImages) {
        try {
          File(image.path).deleteSync();
        } catch (e) {
          debugPrint('Error deleting temp file: $e');
        }
      }
    }
    super.dispose();
  }

  bool get _isValid => _selectedImages.length >= _minPhotos;

  Future<void> _pickImage() async {
    if (_isUploading || _selectedImages.length >= _maxPhotos) return;

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
          if (_errorMessage != null) _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_isValid) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Upload all photos
      for (final image in _selectedImages) {
        final bytes = await image.readAsBytes();
        await ref.read(profileProvider.notifier).uploadPhoto(
          image.path,
          fileBytes: bytes,
        );
      }

      widget.onContinue();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to upload photos: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _selectedImages.length;

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
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Add Your Photos',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.charcoal,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Add $_minPhotos-$_maxPhotos photos to your profile',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.7),
                          ),
                    ),

                    const SizedBox(height: 8),

                    // Explanation about blur
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.sageGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.sageGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your photos will be blurred at Episode 1 and gradually become clearer as you progress through the 7-episode journey with your match.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.charcoal.withOpacity(0.7),
                                        height: 1.4,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Photo preview area
                    _buildPhotoPreviewArea(),

                    const SizedBox(height: 32),

                    // Add photo button
                    if (count < _maxPhotos)
                      GestureDetector(
                        onTap: _isUploading ? null : _pickImage,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: AppTheme.charcoal.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.sageGreen.withOpacity(0.3),
                              style: BorderStyle.solid,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 64,
                                color: AppTheme.sageGreen.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap to add photo',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.charcoal.withOpacity(0.5),
                                    ),
                              ),
                              if (count > 0)
                                Text(
                                  '($count/$_maxPhotos)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.charcoal.withOpacity(0.5),
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    if (count < _maxPhotos) const SizedBox(height: 32),

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
                        onPressed: (_isValid && !_isUploading) ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.terracotta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: AppTheme.terracotta.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isValid ? 'Continue' : 'Add $_minPhotos photo${_minPhotos > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info text about blur progression
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.sageGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: AppTheme.sageGreen,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Progressive Reveal',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Episode 1: Heavily blurred (what you see now)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.charcoal.withOpacity(0.7),
                                ),
                          ),
                          Text(
                            '• Episodes 2-6: Gradually clearer',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.charcoal.withOpacity(0.7),
                                ),
                          ),
                          Text(
                            '• Episode 7: Completely clear',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.charcoal.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
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

  Widget _buildPhotoPreviewArea() {
    if (_selectedImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Photo grid with all photos showing blur preview
        SizedBox(
          height: 400,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Display photo with blur preview
                  _buildBlurredPhoto(_selectedImages[index]),

                  // Photo number badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Remove button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Episode 1 explanation
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppTheme.sageGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.visibility_off,
                color: AppTheme.sageGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Preview: How your photos appear at Episode 1 (heavily blurred)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.charcoal.withOpacity(0.7),
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlurredPhoto(XFile image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo - use different approach for web vs mobile
          _buildPlatformImage(image),

          // Blur overlay (Episode 1 appearance)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Center icon to indicate blur
          const Center(
            child: Icon(
              Icons.blur_on,
              color: Colors.white54,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformImage(XFile image) {
    // On web, XFile.path is a blob URL that works with Image.network
    // On mobile/desktop, we need to use Image.file with a File object
    if (kIsWeb) {
      return Image.network(
        image.path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppTheme.charcoal.withOpacity(0.1),
            child: const Center(
              child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(image.path),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppTheme.charcoal.withOpacity(0.1),
            child: const Center(
              child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
            ),
          );
        },
      );
    }
  }
}
