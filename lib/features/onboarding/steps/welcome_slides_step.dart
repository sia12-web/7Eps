import 'package:flutter/material.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';

/// Welcome slides for steps 1-3 of onboarding
/// Skippable introduction to 7Eps
class WelcomeSlidesStep extends StatefulWidget {
  final int initialSlide;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeSlidesStep({
    super.key,
    this.initialSlide = 0,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<WelcomeSlidesStep> createState() => _WelcomeSlidesStepState();
}

class _WelcomeSlidesStepState extends State<WelcomeSlidesStep> {
  late PageController _pageController;
  late int _currentPage;

  final List<WelcomeSlideData> _slides = const [
    WelcomeSlideData(
      title: '3-5 Quality Matches Daily',
      description:
          'No endless swiping. No overwhelming options. Just a curated selection of compatible people each day.',
      icon: Icons.favorite_border,
    ),
    WelcomeSlideData(
      title: '7 Episodes → Real Date',
      description:
          'Progressive disclosure through a 7-episode journey. Share your story gradually as you build a genuine connection.',
      icon: Icons.menu_book,
    ),
    WelcomeSlideData(
      title: '3 Active Journeys Max',
      description:
          'Quality over quantity. Focus on meaningful connections without spreading yourself too thin.',
      icon: Icons.people_outline,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialSlide;
    _pageController = PageController(initialPage: widget.initialSlide);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: widget.onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppTheme.charcoal.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // PageView for slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.sageGreen
                        : AppTheme.charcoal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Continue/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.terracotta,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(WelcomeSlideData slide) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.sageGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 64,
              color: AppTheme.sageGreen,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.charcoal,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              slide.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.charcoal.withOpacity(0.7),
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeSlideData {
  final String title;
  final String description;
  final IconData icon;

  const WelcomeSlideData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
