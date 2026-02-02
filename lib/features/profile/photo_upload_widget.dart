import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/providers/profile_provider.dart';

class PhotoUploadWidget extends ConsumerStatefulWidget {
  final List photos;
  final VoidCallback onPhotoUploaded;
  final Future<void> Function(String photoId) onPhotoDeleted;

  const PhotoUploadWidget({
    super.key,
    required this.photos,
    required this.onPhotoUploaded,
    required this.onPhotoDeleted,
  });

  @override
  ConsumerState<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends ConsumerState<PhotoUploadWidget> {
  bool _isUploading = false;

  Future<void> _pickImage() async {
    debugPrint('🖼️ _pickImage called');
    if (_isUploading) {
      debugPrint('⚠️ Already uploading, ignoring click');
      return;
    }

    debugPrint('📷 Opening image picker...');
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      debugPrint('✅ Image selected:');
      debugPrint('   - Name: ${image.name}');
      debugPrint('   - Path: ${image.path}');

      // Check if already at max 3 photos
      if (widget.photos.length >= 3) {
        debugPrint('❌ Max 3 photos reached');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 3 photos allowed. Delete a photo first.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        debugPrint('📖 Reading file bytes...');
        // Read file bytes for web compatibility
        final bytes = await image.readAsBytes();
        debugPrint('✅ File bytes read: ${bytes.length} bytes');

        debugPrint('⬆️ Calling uploadPhoto...');
        // Call upload with both path and bytes
        await ref.read(profileProvider.notifier).uploadPhoto(
              image.path,
              fileBytes: bytes,
            );

        debugPrint('✅ Upload completed successfully');
        if (mounted) {
          widget.onPhotoUploaded();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully!'),
              backgroundColor: AppTheme.sageGreen,
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Upload failed in widget: $e');
        debugPrint('❌ StackTrace: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
          debugPrint('♻️ Upload state reset');
        }
      }
    } else {
      debugPrint('❌ No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (${widget.photos.length}/3)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Photo slots
              ...List.generate(3, (index) {
              if (index < widget.photos.length) {
                // Show existing photo
                return GestureDetector(
                  onTap: () => _showDeleteDialog(context, widget.photos[index].id),
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.charcoal.withOpacity(0.2)),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: CachedNetworkImage(
                            imageUrl: widget.photos[index].url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppTheme.charcoal.withOpacity(0.1),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppTheme.charcoal.withOpacity(0.1),
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),
                        // Delete button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _showDeleteDialog(context, widget.photos[index].id),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),
                );
              } else {
                // Empty slot or uploading
                return GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _isUploading
                          ? AppTheme.charcoal.withOpacity(0.1)
                          : AppTheme.charcoal.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.charcoal.withOpacity(0.2),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _isUploading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                color: AppTheme.charcoal.withOpacity(0.4),
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.charcoal.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }
            }),
          ],
        ),
          ),
        const SizedBox(height: 8),
        Text(
          'Tap to add or change photos (max 3)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.charcoal.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String photoId) {
    debugPrint('🗑️ Delete dialog opened for photo ID: $photoId');
    debugPrint('🗑️ Current photos count: ${widget.photos.length}');
    if (widget.photos.isNotEmpty && widget.photos[0].id != null) {
      debugPrint('🗑️ First photo ID in list: ${widget.photos[0].id}');
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              debugPrint('🗑️ User confirmed delete');
              await widget.onPhotoDeleted(photoId);
              if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
