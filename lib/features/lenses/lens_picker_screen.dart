import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/lens.dart';
import 'package:sevent_eps/providers/lens_provider.dart';

class LensPickerScreen extends ConsumerStatefulWidget {
  const LensPickerScreen({super.key});

  @override
  ConsumerState<LensPickerScreen> createState() => _LensPickerScreenState();
}

class _LensPickerScreenState extends ConsumerState<LensPickerScreen> {
  final Set<String> _selectedLensIds = {};

  @override
  void initState() {
    super.initState();
    // Pre-select existing lenses
    final asyncUserLenses = ref.read(userLensesProvider);
    asyncUserLenses.whenData((lenses) {
      if (lenses.length == 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _selectedLensIds.clear();
            _selectedLensIds.addAll(lenses.map((ul) => ul.lens.id));
          });
        });
      }
    });
  }

  bool get _canSave => _selectedLensIds.length == 3;

  void _toggleLens(String lensId) {
    setState(() {
      if (_selectedLensIds.contains(lensId)) {
        _selectedLensIds.remove(lensId);
      } else if (_selectedLensIds.length < 3) {
        _selectedLensIds.add(lensId);
      }
    });
  }

  Future<void> _saveLenses() async {
    if (!_canSave) return;

    try {
      await ref.read(userLensesProvider.notifier).saveUserLenses(
        _selectedLensIds.toList(),
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lenses saved! Your editions will now be tuned to these preferences.'),
            backgroundColor: AppTheme.sageGreen,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving lenses: $e'),
            backgroundColor: AppTheme.terracotta,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncLenses = ref.watch(allLensesProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Choose 3 Lenses',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.charcoal,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${_selectedLensIds.length}/3',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _canSave ? AppTheme.sageGreen : AppTheme.charcoal.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Subtitle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Text(
              'These guide what we prioritize — not who you\'re allowed to meet.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.charcoal.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          // Lenses list
          Expanded(
            child: asyncLenses.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.sageGreen),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.terracotta.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load lenses',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.charcoal,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.charcoal.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => ref.read(allLensesProvider.notifier).refresh(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.sageGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (lenses) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: lenses.length,
                itemBuilder: (context, index) {
                  final lens = lenses[index];
                  final isSelected = _selectedLensIds.contains(lens.id);
                  final isDisabled = !isSelected && _selectedLensIds.length >= 3;

                  return _LensCard(
                    lens: lens,
                    isSelected: isSelected,
                    isDisabled: isDisabled,
                    onTap: isDisabled ? null : () => _toggleLens(lens.id),
                  );
                },
              ),
            ),
          ),

          // Save button
          Container(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSave ? _saveLenses : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSave ? AppTheme.terracotta : AppTheme.charcoal.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.charcoal.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _canSave ? 'Save Lenses' : 'Select 3 Lenses',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LensCard extends StatelessWidget {
  final Lens lens;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _LensCard({
    required this.lens,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.sageGreen.withOpacity(0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppTheme.sageGreen
                    : AppTheme.charcoal.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.charcoal.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and checkbox
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lens.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.charcoal,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.sageGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      )
                    else if (!isDisabled)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.charcoal.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  lens.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.charcoal.withOpacity(0.7),
                      ),
                ),

                const SizedBox(height: 12),

                // Example signals
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lens.exampleSignals.take(4).map((signal) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.sageGreen.withOpacity(0.2)
                            : AppTheme.charcoal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        signal,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.charcoal.withOpacity(0.7),
                              fontSize: 11,
                            ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
