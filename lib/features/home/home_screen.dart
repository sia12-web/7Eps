import 'package:flutter/material.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 80,
              color: AppTheme.sageGreen,
            ),
            const SizedBox(height: 24),
            Text(
              '7Eps',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your journey begins soon...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.charcoal.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 48),
            Text(
              'Daily Edition coming in Phase 3',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.terracotta,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
