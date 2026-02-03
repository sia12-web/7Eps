import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_logo.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Logo/Title
              const AppLogo(size: 180, showText: false),
              const SizedBox(height: 24),

              Text(
                '7 Episodes to Connection',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF3D3D3D).withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Login Button
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 16),

              // Register Button
              ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87A878), // Sage
                ),
                child: const Text('Create Account'),
              ),

              const Spacer(),

              // Tagline
              Text(
                'Meaningful connections, one episode at a time',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF3D3D3D).withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
