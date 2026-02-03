import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sevent_eps/models/lens.dart';

class LensState extends StateNotifier<AsyncValue<List<Lens>>> {
  LensState() : super(const AsyncValue.loading()) {
    loadLenses();
  }

  Future<void> loadLenses() async {
    state = const AsyncValue.loading();
    try {
      final response = await Supabase.instance.client
          .from('lenses')
          .select()
          .order('sort_order');

      final lenses = (response as List<dynamic>)
          .map((e) => Lens.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(lenses);
      debugPrint('✅ Loaded ${lenses.length} lenses');
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading lenses: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() => loadLenses();
}

class UserLensState extends StateNotifier<AsyncValue<List<UserLens>>> {
  UserLensState() : super(const AsyncValue.loading()) {
    loadUserLenses();
  }

  Future<void> loadUserLenses() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final response = await Supabase.instance.client.rpc('get_user_lenses', params: {
        'p_user_id': userId,
      });

      final userLenses = <UserLens>[];
      if (response != null) {
        for (var item in response as List<dynamic>) {
          userLenses.add(UserLens.fromJson(item as Map<String, dynamic>));
        }
      }

      state = AsyncValue.data(userLenses);
      debugPrint('✅ Loaded ${userLenses.length} user lenses');
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading user lenses: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> saveUserLenses(List<String> lensIds) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    if (lensIds.length != 3) {
      throw Exception('Must select exactly 3 lenses');
    }

    try {
      await Supabase.instance.client.rpc('save_user_lenses', params: {
        'p_lens_ids': lensIds,
        'p_user_id': userId,
      });

      await loadUserLenses();
      debugPrint('✅ Saved 3 lenses for user');
    } catch (e) {
      debugPrint('❌ Error saving lenses: $e');
      rethrow;
    }
  }

  Future<void> refresh() => loadUserLenses();
}

// Providers
final allLensesProvider =
    StateNotifierProvider<LensState, AsyncValue<List<Lens>>>((ref) {
  return LensState();
});

final userLensesProvider =
    StateNotifierProvider<UserLensState, AsyncValue<List<UserLens>>>((ref) {
  return UserLensState();
});

/// Whether user has selected lenses
final hasSelectedLensesProvider = Provider<bool>((ref) {
  final asyncLenses = ref.watch(userLensesProvider);
  return asyncLenses.value?.length == 3;
});

/// Get user's 3 lenses as a list
final userSelectedLensesProvider = Provider<List<Lens>>((ref) {
  final asyncUserLenses = ref.watch(userLensesProvider);
  return asyncUserLenses.value?.map((ul) => ul.lens).toList() ?? [];
});
