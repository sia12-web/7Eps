import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for Supabase client instance
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Auth state provider - tracks if user is signed in
class AuthState extends StateNotifier<bool> {
  AuthState() : super(false) {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      state = session != null;
    });
  }
}

final authStateProvider = StateNotifierProvider<AuthState, bool>((ref) {
  return AuthState();
});

/// Initialize Supabase with your credentials
///
/// Call this in main.dart before runApp()
Future<void> initializeSupabase() async {
  // Supabase credentials
  const supabaseUrl = 'https://mmvuzxtrweshvvyhmarv.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1tdnV6eHRyd2VzaHZ2eWhtYXJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4MTg5MzMsImV4cCI6MjA4NTM5NDkzM30.f-3NyJ2tRxIPZA_vtBV4P0aCWj9kIvu1GDGfpey8nJA';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: kDebugMode,
  );
}
