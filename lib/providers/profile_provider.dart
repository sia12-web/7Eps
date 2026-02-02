import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sevent_eps/models/profile.dart';
import 'package:sevent_eps/models/profile_photo.dart';

class ProfileState extends StateNotifier<AsyncValue<Profile?>> {
  ProfileState() : super(const AsyncValue.data(null)) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    debugPrint('🔄 _loadProfile called');
    final userId = Supabase.instance.client.auth.currentUser?.id;
    debugPrint('🔄 User ID: $userId');

    if (userId == null) {
      debugPrint('⚠️ No user ID, setting profile to null');
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    try {
      debugPrint('🔍 Querying database for profile...');
      final response = await Supabase.instance.client
          .from('profiles')
          .select(
            '*, profile_photos(id, url, sort_order, created_at)',
          )
          .eq('user_id', userId)
          .maybeSingle();  // Use maybeSingle() instead of single() to handle no profile

      debugPrint('🔍 Response received: ${response != null}');
      if (response != null) {
        debugPrint('🔍 Raw response keys: ${response.keys.toList()}');
        debugPrint('🔍 Has profile_photos: ${response['profile_photos'] != null}');
        if (response['profile_photos'] != null) {
          debugPrint('🔍 Photos count: ${response['profile_photos'] is List ? (response['profile_photos'] as List).length : "not a list"}');
        }
      }

      // Map profile_photos to photos for the model
      if (response != null && response['profile_photos'] != null) {
        response['photos'] = response['profile_photos'];
        response.remove('profile_photos');
        debugPrint('🔄 Mapped profile_photos -> photos');
      }

      if (response != null) {
        debugPrint('📦 Parsing profile from JSON...');
        final profile = Profile.fromJson(response);
        debugPrint('✅ Profile loaded: ${profile.name}, ${profile.photos.length} photos');
        state = AsyncValue.data(profile);
      } else {
        // No profile exists yet (user in onboarding)
        debugPrint('⚠️ No profile found (user in onboarding)');
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR loading profile: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      // If profile doesn't exist or other error, set to null
      state = const AsyncValue.data(null);
    }
    debugPrint('✅ _loadProfile complete');
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    String? bio,
    List<String>? interests,
    String? city,
    String? university,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    state = const AsyncValue.loading();
    try {
      await Supabase.instance.client.from('profiles').update({
        'name': name,
        'age': age,
        'bio': bio,
        'interests': interests,
        'city': city,
        'university': university,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      await _loadProfile();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> uploadPhoto(String filePath, {Uint8List? fileBytes}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    debugPrint('📸 ===== PHOTO UPLOAD STARTED =====');
    debugPrint('📸 User ID: $userId');

    if (userId == null) {
      debugPrint('❌ ERROR: Not authenticated');
      throw Exception('Not authenticated');
    }

    try {
      // Check if profile exists
      debugPrint('🔍 Checking if profile exists...');
      final existingProfile = await Supabase.instance.client
          .from('profiles')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      debugPrint('🔍 Profile exists: ${existingProfile != null}');

      // Create profile if it doesn't exist (onboarding scenario)
      if (existingProfile == null) {
        debugPrint('➕ Creating placeholder profile...');
        await Supabase.instance.client.from('profiles').insert({
          'user_id': userId,
          'name': '',  // Will be filled in during onboarding
          'age': 0,
        });
        debugPrint('✅ Placeholder profile created');
      }

      state = const AsyncValue.loading();

      // Upload file to Supabase Storage
      // Extract file extension from the path (handle blob URLs on web)
      String fileExt = 'jpg'; // default
      if (filePath.contains('.')) {
        final parts = filePath.split('.');
        fileExt = parts.last.toLowerCase();
        // Remove any query parameters or URL fragments
        fileExt = fileExt.split('?')[0].split('#')[0];
      }

      // Generate a clean filename with timestamp and extension
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId/$timestamp.$fileExt';
      debugPrint('📤 File name: $fileName');
      debugPrint('📤 File extension: $fileExt');
      debugPrint('📤 Platform is Web: $kIsWeb');

      // For web, use fileBytes; for mobile, use File
      if (kIsWeb && fileBytes != null) {
        debugPrint('📤 UploadBinary - File size: ${fileBytes.length} bytes');
        await Supabase.instance.client.storage.from('profile-photos').uploadBinary(
              fileName,
              fileBytes,
            );
        debugPrint('✅ UploadBinary successful');
      } else if (!kIsWeb) {
        debugPrint('📤 Upload from file path: $filePath');
        await Supabase.instance.client.storage.from('profile-photos').upload(
              fileName,
              File(filePath),
            );
        debugPrint('✅ Upload successful');
      } else {
        debugPrint('❌ ERROR: No file data provided');
        throw Exception('No file data provided for web upload');
      }

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from('profile-photos')
          .getPublicUrl(fileName);
      debugPrint('🔗 Public URL: $publicUrl');

      // Save to database
      debugPrint('💾 Saving to database...');
      final insertData = {
        'user_id': userId,
        'url': publicUrl,
        'sort_order': DateTime.now().millisecondsSinceEpoch,
      };
      debugPrint('💾 Insert data: $insertData');

      await Supabase.instance.client.from('profile_photos').insert(insertData);
      debugPrint('✅ Saved to database successfully');

      debugPrint('🔄 Reloading profile...');
      await _loadProfile();
      debugPrint('✅ ===== PHOTO UPLOAD COMPLETE =====');

    } catch (e, stackTrace) {
      debugPrint('❌❌❌ PHOTO UPLOAD FAILED ❌❌❌');
      debugPrint('❌ Error: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deletePhoto(String photoId) async {
    debugPrint('🗑️ ===== DELETE PHOTO STARTED =====');
    debugPrint('🗑️ Photo ID to delete: $photoId');

    try {
      debugPrint('🗑️ Deleting from database...');
      final response = await Supabase.instance.client
          .from('profile_photos')
          .delete()
          .eq('id', photoId);

      debugPrint('✅ Delete response: $response');
      debugPrint('🔄 Reloading profile...');
      await _loadProfile();
      debugPrint('✅ ===== DELETE PHOTO COMPLETE =====');
    } catch (e, stackTrace) {
      debugPrint('❌ DELETE FAILED: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> refresh() => _loadProfile();
}

final profileProvider =
    StateNotifierProvider<ProfileState, AsyncValue<Profile?>>((ref) {
  return ProfileState();
});

/// Convenience provider to get the current profile value
final currentProfileProvider = Provider<Profile?>((ref) {
  final asyncProfile = ref.watch(profileProvider);
  return asyncProfile.value;
});
