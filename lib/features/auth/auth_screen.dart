import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              Text(
                '7Eps',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: const Color(0xFFC17F59), // Terracotta
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                '7 Episodes to Connection',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF3D3D3D).withOpacity(0.7),
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
