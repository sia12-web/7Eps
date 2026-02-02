import 'package:flutter/material.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/features/profile/edit_profile_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditProfileScreen(
      isOnboarding: true,
    );
  }
}
