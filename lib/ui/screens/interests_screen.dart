import 'package:flutter/material.dart';

import '../../Data/categories.dart';
import '../utils/app_theme.dart';

class InterestsScreen extends StatefulWidget {
  final List<String> currentInterests;

  const InterestsScreen({super.key, required this.currentInterests});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  late final Set<String> _selected = {...widget.currentInterests};

  void _toggle(String category) {
    setState(() {
      if (_selected.contains(category)) {
        _selected.remove(category);
      } else {
        _selected.add(category);
      }
    });
  }

  void _save() {
    final interests = allCategories.where(_selected.contains).toList();
    Navigator.pop(context, interests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Interests')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pick the topics you want to see. Your feed will only show these.',
              style: TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allCategories.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: _selected.contains(category),
                  onSelected: (_) => _toggle(category),
                  selectedColor: AppTheme.accent.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.accent,
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selected.isEmpty ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save interests'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
