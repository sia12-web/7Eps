import 'package:flutter/material.dart';
import 'package:sevent_eps/models/interests.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';

class InterestsSelector extends StatefulWidget {
  final List<String> selectedInterests;
  final ValueChanged<List<String>> onInterestsChanged;

  const InterestsSelector({
    super.key,
    required this.selectedInterests,
    required this.onInterestsChanged,
  });

  @override
  State<InterestsSelector> createState() => _InterestsSelectorState();
}

class _InterestsSelectorState extends State<InterestsSelector> {
  final _searchController = TextEditingController();
  List<String> _filteredInterests = commonInterests;
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterInterests(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredInterests = commonInterests;
      } else {
        _filteredInterests = commonInterests
            .where((interest) => interest.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleInterest(String interest) {
    final updated = List<String>.from(widget.selectedInterests);
    if (updated.contains(interest)) {
      updated.remove(interest);
    } else {
      if (updated.length < 10) {
        // Max 10 interests
        updated.add(interest);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 10 interests allowed'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }
    widget.onInterestsChanged(updated);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search and category filter
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Interests',
                  hintText: 'E.g., hiking, cooking...',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: _filterInterests,
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _selectedCategory,
              items: ['All', ...interestCategories.keys]
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    if (value == 'All') {
                      _filteredInterests = commonInterests;
                    } else {
                      _filteredInterests = interestCategories[value]!;
                    }
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Selected: ${widget.selectedInterests.length}/10',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.charcoal.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),

        // Selected interests chips
        if (widget.selectedInterests.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedInterests.map((interest) {
              return Chip(
                label: Text(interest),
                onDeleted: () => _toggleInterest(interest),
                backgroundColor: AppTheme.terracotta.withOpacity(0.1),
                deleteIconColor: AppTheme.terracotta,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Available interests
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredInterests.length,
            itemBuilder: (context, index) {
              final interest = _filteredInterests[index];
              final isSelected = widget.selectedInterests.contains(interest);
              return CheckboxListTile(
                title: Text(interest),
                value: isSelected,
                onChanged: (_) => _toggleInterest(interest),
                dense: true,
                activeColor: AppTheme.terracotta,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
