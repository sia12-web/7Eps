import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevent_eps/app.dart';
import 'package:sevent_eps/core/supabase/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await initializeSupabase();

  runApp(
    const ProviderScope(
      child: SevenEpsApp(),
    ),
  );
}
