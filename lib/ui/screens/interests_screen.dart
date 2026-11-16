import 'package:flutter/material.dart';

import '../../Data/categories.dart';
import '../utils/app_theme.dart';

class InterestsScreen extends StatefulWidget {
  final List<String> currentInterests;
  final bool isWelcome;

  const InterestsScreen({
    super.key,
    required this.currentInterests,
    this.isWelcome = false,
  });

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  late final Set<String> _selected = widget.isWelcome ? {} : {...widget.currentInterests};

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
    return PopScope(
      canPop: !widget.isWelcome,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !widget.isWelcome,
          title: Text(
            widget.isWelcome ? 'Welcome to Echorithm' : 'My Interests',
          ),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isWelcome
                    ? 'What do you like to read about? Pick your topics and we will build your feed.'
                    : 'Pick the topics you care about. Your For You feed mixes these.',
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 15),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: allCategories.map((category) {
                  return _TopicChip(
                    label: category,
                    isSelected: _selected.contains(category),
                    onTap: () => _toggle(category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                '${_selected.length} of ${allCategories.length} topics selected',
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected.isEmpty ? null : _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _selected.isEmpty
                        ? 'Pick at least one topic'
                        : 'Save interests',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopicChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent
                : AppTheme.textGrey.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.textGrey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
