import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Auth extends StateNotifier<bool> {
  Auth() : super(Supabase.instance.client.auth.currentSession != null) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      state = data.session != null;
    });
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    // Parse common Supabase auth errors
    if (errorString.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (errorString.contains('Email not confirmed')) {
      return 'Please verify your email first. Check your inbox for the confirmation link.';
    }
    if (errorString.contains('User already registered')) {
      return 'An account with this email already exists. Try logging in instead.';
    }
    if (errorString.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (errorString.contains('Password should be at least')) {
      return 'Password must be at least 6 characters long.';
    }
    if (errorString.contains('Unable to validate email address')) {
      return 'Please enter a valid email address.';
    }

    // Default fallback
    if (errorString.contains('Exception: ')) {
      final cleaned = errorString.replaceAll('Exception: ', '');
      if (cleaned.length < 50) {
        return cleaned;
      }
    }

    return 'Something went wrong. Please try again.';
  }

  Future<void> signIn(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

    if (response.user == null) {
      throw Exception(_getErrorMessage(response));
    }

    state = true;
  }

  Future<void> signUp(String email, String password) async {
    final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

    if (response.user == null) {
      throw Exception(_getErrorMessage(response));
    }

    // Don't set state to true yet - user needs to verify email
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = false;
  }

  User? get currentUser => Supabase.instance.client.auth.currentUser;
}

final authProvider = StateNotifierProvider<Auth, bool>((ref) {
  return Auth();
});
