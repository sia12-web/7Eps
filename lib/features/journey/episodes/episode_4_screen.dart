import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/episode.dart';
import 'package:sevent_eps/models/artifact.dart';
import 'package:sevent_eps/providers/artifact_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Episode4Screen extends ConsumerStatefulWidget {
  final String matchId;

  const Episode4Screen({super.key, required this.matchId});

  @override
  ConsumerState<Episode4Screen> createState() => _Episode4ScreenState();
}

class _Episode4ScreenState extends ConsumerState<Episode4Screen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploading = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final episodeDef = episodeDefinitions[4] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(episodeDef['title'] ?? 'Episode 4'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Episode info
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.sageGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Episode 4 of 7',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.sageGreen,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    episodeDef['description'] ?? 'Share a photo',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.charcoal.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Prompt
            Text(
              episodeDef['prompt'] ?? 'Upload your candid photo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Photo upload area
            GestureDetector(
              onTap: _isUploading || _isSubmitting ? null : _pickImage,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: _selectedImage != null
                      ? AppTheme.charcoal.withOpacity(0.05)
                      : AppTheme.charcoal.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.charcoal.withOpacity(0.2),
                    style: BorderStyle.solid,
                  ),
                ),
                child: _buildPhotoContent(),
              ),
            ),

            const SizedBox(height: 32),

            // Re-upload button (if image selected)
            if (_selectedImage != null && !_isUploading && !_isSubmitting)
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.refresh),
                label: const Text('Choose Different Photo'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.charcoal.withOpacity(0.7),
                ),
              ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedImage == null || _isSubmitting || _isUploading)
                    ? null
                    : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: AppTheme.terracotta.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Photo'),
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Text(
              'Share a candid, authentic photo of yourself',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.charcoal.withOpacity(0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoContent() {
    if (_isUploading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 16),
            Text('Uploading...'),
          ],
        ),
      );
    }

    if (_selectedImage != null) {
      if (_selectedImage!.path.startsWith('http')) {
        // Network image preview
        return ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Image.network(
            _selectedImage!.path,
            width: 280,
            height: 280,
            fit: BoxFit.cover,
          ),
        );
      } else {
        // Local file preview
        return ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Image.file(
            File(_selectedImage!.path),
            width: 280,
            height: 280,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    // Empty state
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.photo_camera,
          size: 64,
          color: AppTheme.charcoal.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to upload',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.charcoal.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    if (_isUploading || _isSubmitting) return;

    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedImage == null) return;

    setState(() {
      _isSubmitting = true;
      _isUploading = true;
    });

    try {
      // Upload to Supabase Storage
      debugPrint('📸 ===== UPLOAD EPISODE 4 PHOTO =====');
      debugPrint('📸 Match ID: ${widget.matchId}');

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Not authenticated');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'episode_4_${widget.matchId}_$userId.jpg';
      final filePath = '$userId/episode_artifacts/$fileName';

      debugPrint('📸 Uploading to: $filePath');

      // Read file bytes
      final bytes = await _selectedImage!.readAsBytes();
      debugPrint('📸 File size: ${bytes.length} bytes');

      // Upload to Supabase Storage
      await Supabase.instance.client.storage.from('photos').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final photoUrl = Supabase.instance.client.storage.from('photos').getPublicUrl(filePath);
      debugPrint('✅ Photo uploaded: $photoUrl');

      // Submit artifact
      await ref.read(artifactProvider.notifier).submitArtifact(
        matchId: widget.matchId,
        artifactType: ArtifactType.photo.name,
        payload: {'photo_url': photoUrl},
      );

      debugPrint('✅ Artifact submitted successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo submitted successfully!'),
            backgroundColor: AppTheme.sageGreen,
          ),
        );
        context.pop();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isUploading = false;
        });
      }
    }
  }
}
