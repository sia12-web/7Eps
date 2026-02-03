import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            '7Eps',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: const Color(0xFFC17F59), // Terracotta
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
          ),
        ],
      ],
    );
  }
}
