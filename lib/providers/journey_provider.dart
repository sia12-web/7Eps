import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sevent_eps/models/profile.dart';

class JourneyState extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  JourneyState() : super(const AsyncValue.loading());

  Future<void> loadJourney(String matchId) async {
    debugPrint('📖 ===== LOAD JOURNEY =====');
    debugPrint('📖 Match ID: $matchId');

    state = const AsyncValue.loading();
    try {
      // Get current user ID
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('Not authenticated');
      }

      debugPrint('🔍 Fetching match and participants...');

      // Fetch match with participants
      final matchResponse = await Supabase.instance.client
          .from('matches')
          .select('*, match_participants(user_id)')
          .eq('id', matchId)
          .single();

      debugPrint('📦 Match response received');

      // Find partner's user ID (the other participant)
      final participants = matchResponse['match_participants'] as List;
      String? partnerUserId;
      for (var p in participants) {
        final userId = p['user_id'] as String?;
        if (userId != currentUserId) {
          partnerUserId = userId;
          break;
        }
      }

      if (partnerUserId == null) {
        throw Exception('Partner not found');
      }

      debugPrint('👫 Partner User ID: $partnerUserId');

      // Fetch partner's profile with photos
      debugPrint('🔍 Fetching partner profile...');
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('*, profile_photos(id, url, sort_order)')
          .eq('user_id', partnerUserId)
          .maybeSingle();

      debugPrint('📦 Partner profile received: ${profileResponse != null}');

      if (profileResponse == null) {
        throw Exception('Partner profile not found');
      }

      // Map profile photos to photos field
      if (profileResponse['profile_photos'] != null) {
        profileResponse['photos'] = profileResponse['profile_photos'];
        profileResponse.remove('profile_photos');
      }

      final partnerProfile = Profile.fromJson(profileResponse);

      debugPrint('✅ Partner profile loaded: ${partnerProfile.name}');
      debugPrint('   - Photos: ${partnerProfile.photos.length}');

      state = AsyncValue.data({
        'match': matchResponse,
        'partner': partnerProfile,
        'currentUserId': currentUserId,
      });
      debugPrint('✅ ===== JOURNEY LOAD COMPLETE =====');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR loading journey: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    if (state is AsyncData<Map<String, dynamic>>) {
      final data = state as AsyncData<Map<String, dynamic>>;
      final matchId = data.value['match']['id'] as String;
      await loadJourney(matchId);
    }
  }
}

final journeyProvider =
    StateNotifierProvider<JourneyState, AsyncValue<Map<String, dynamic>>>((ref) {
  return JourneyState();
});

/// Provider to get journey data for a specific match ID
final journeyDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, matchId) {
  throw UnimplementedError('Use journeyProvider.notifier.loadJourney(matchId) instead');
});
