import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevent_eps/core/router/router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/core/supabase/supabase_client.dart';

class SevenEpsApp extends ConsumerStatefulWidget {
  const SevenEpsApp({super.key});

  @override
  ConsumerState<SevenEpsApp> createState() => _SevenEpsAppState();
}

class _SevenEpsAppState extends ConsumerState<SevenEpsApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Supabase auth state listener
    ref.read(authStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '7Eps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
