import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevent_eps/features/auth/auth_screen.dart';
import 'package:sevent_eps/features/auth/login_screen.dart';
import 'package:sevent_eps/features/auth/register_screen.dart';
import 'package:sevent_eps/features/profile/onboarding_screen.dart';
import 'package:sevent_eps/features/profile/edit_profile_screen.dart';
import 'package:sevent_eps/features/home/home_screen.dart';
import 'package:sevent_eps/features/daily_edition/daily_edition_screen.dart';
import 'package:sevent_eps/features/journey/journeys_list_screen.dart';
import 'package:sevent_eps/features/journey/journey_screen.dart';
import 'package:sevent_eps/features/journey/episodes/episode_1_screen.dart';
import 'package:sevent_eps/features/journey/episodes/episode_2_screen.dart';
import 'package:sevent_eps/features/journey/episodes/episode_3_screen.dart';
import 'package:sevent_eps/features/journey/episodes/episode_4_screen.dart';
import 'package:sevent_eps/features/onboarding/onboarding_flow_screen.dart';
import 'package:sevent_eps/providers/auth_provider.dart';
import 'package:sevent_eps/providers/profile_provider.dart';
import 'package:sevent_eps/providers/onboarding_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      // If not authenticated, redirect to auth
      if (!authState) {
        final isOnAuthRoute = state.matchedLocation == '/auth' ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        if (!isOnAuthRoute) {
          return '/auth';
        }
      }

      // If authenticated and on auth route, check onboarding status
      if (authState) {
        final isOnAuthRoute = state.matchedLocation == '/auth' ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        if (isOnAuthRoute) {
          // Check onboarding status (async, so we won't block)
          // The onboarding screen will handle redirect based on completion
          return '/onboarding/1';
        }

        // Check if user is trying to access protected routes without completing onboarding
        // Note: This is a simple check - for full protection, the onboarding provider
        // should be watched in the build method of each protected screen
        final isOnProtectedRoute = state.matchedLocation == '/daily-edition' ||
                                  state.matchedLocation == '/journeys' ||
                                  state.matchedLocation.startsWith('/journey/');

        if (isOnProtectedRoute && state.matchedLocation != '/onboarding/1' &&
            !state.matchedLocation.startsWith('/onboarding/')) {
          // Let the onboarding screen decide if redirect is needed
          // This prevents loops while allowing resume functionality
          return null;
        }
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Old Onboarding Route (kept for backwards compatibility during transition)
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // New Multi-Step Onboarding Route
      GoRoute(
        path: '/onboarding/:step',
        name: 'onboarding-step',
        builder: (context, state) {
          final stepParam = state.pathParameters['step'] ?? '1';
          final step = int.tryParse(stepParam) ?? 1;
          return OnboardingFlowScreen(initialStep: step);
        },
      ),

      // Home Route - redirect to journeys
      GoRoute(
        path: '/',
        name: 'home',
        redirect: (context, state) => '/journeys',
      ),

      // Journeys List Route
      GoRoute(
        path: '/journeys',
        name: 'journeys',
        builder: (context, state) => const JourneysListScreen(),
      ),

      // Daily Edition Route
      GoRoute(
        path: '/daily-edition',
        name: 'daily-edition',
        builder: (context, state) => const DailyEditionScreen(),
      ),

      // Profile Routes
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Journey Detail Route with nested episode routes
      GoRoute(
        path: '/journey/:matchId',
        name: 'journey',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId']!;
          return JourneyScreen(matchId: matchId);
        },
        routes: [
          // Episode submission routes
          GoRoute(
            path: 'episode/:episodeNumber',
            name: 'episode',
            builder: (context, state) {
              final matchId = state.pathParameters['matchId']!;
              final episodeNumber = int.parse(state.pathParameters['episodeNumber']!);
              return _getEpisodeScreen(matchId, episodeNumber);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('404 - ${state.uri}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/auth'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Helper function to route to the correct episode screen based on episode number
Widget _getEpisodeScreen(String matchId, int episodeNumber) {
  switch (episodeNumber) {
    case 1:
      return Episode1Screen(matchId: matchId);
    case 2:
      return Episode2Screen(matchId: matchId);
    case 3:
      return Episode3Screen(matchId: matchId);
    case 4:
      return Episode4Screen(matchId: matchId);
    default:
      // For episodes 5-7, not yet implemented
      return const Scaffold(
        body: Center(
          child: Text('Coming Soon'),
        ),
      );
  }
}
