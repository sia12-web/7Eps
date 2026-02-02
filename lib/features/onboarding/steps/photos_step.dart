import 'dart:io';
import 'dart:ui';
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
    // Clean up temporary files
    for (final image in _selectedImages) {
      try {
        File(image.path).deleteSync();
      } catch (e) {
        debugPrint('Error deleting temp file: $e');
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
                      'Min $_minPhotos, max $_maxPhotos',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.7),
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

                    // Info text about blur
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
                                  'Your photos will be blurred at Episode 1 and gradually unblur as you progress through the journey.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.charcoal.withOpacity(0.7),
                                      ),
                                ),
                              ),
                            ],
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
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              // Display first photo with blur preview
              _buildBlurredPhoto(_selectedImages[0]),

              // Photo indicators
              if (_selectedImages.length > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_selectedImages.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == 0 ? AppTheme.sageGreen : AppTheme.charcoal.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Remove button
        if (_selectedImages.isNotEmpty)
          TextButton.icon(
            onPressed: () => _removeImage(0),
            icon: const Icon(Icons.delete_outline, color: AppTheme.terracotta),
            label: const Text('Remove photo'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.terracotta,
            ),
          ),
      ],
    );
  }

  Widget _buildBlurredPhoto(XFile image) {
    return Stack(
      children: [
        // Photo
        Image.file(
          File(image.path),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),

        // Blur overlay (Episode 1 appearance)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // "Episode 1 Preview" badge
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.sageGreen.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Episode 1 Preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Tap to preview text
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'This is how you appear at Episode 1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
