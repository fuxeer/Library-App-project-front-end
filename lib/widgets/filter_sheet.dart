// Assume the necessary imports for Riverpod, Flutter, and the FilterState/FilterNotifier are available.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_app/providers/filter_provider.dart';

class _FilterSheet extends ConsumerStatefulWidget {
  final List<String> categories;

  const _FilterSheet({required this.categories});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  // Local state for the bottom sheet (only for text field controllers)
  late String category;
  late double minRating;
  late String sortBy;
  late bool descending;
  late int? fromYear;
  late int? toYear;

  late TextEditingController fromYearController;
  late TextEditingController toYearController;

  @override
  void initState() {
    super.initState();
    // 1. Read the current global state from the provider to initialize local variables
    // This ensures the sheet opens with the current active filters.
    final initial = ref.read(filterProvider);

    category = initial.category;
    minRating = initial.minRating;
    sortBy = initial.sortBy;
    descending = initial.descending;
    fromYear = initial.fromYear;
    toYear = initial.toYear;

    fromYearController = TextEditingController(
      text: fromYear?.toString() ?? '',
    );
    toYearController = TextEditingController(text: toYear?.toString() ?? '');
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    fromYearController.dispose();
    toYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read the filter notifier for state updates
    final filterNotifier = ref.read(filterProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          const Text(
            'Filters',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),
          // Category dropdown menu
          DropdownButtonFormField<String>(
            initialValue: category.isEmpty ? '' : category,
            items: [
              const DropdownMenuItem(value: '', child: Text('Any')),
              ...widget.categories.map(
                (c) => DropdownMenuItem(value: c, child: Text(c)),
              ),
            ],
            onChanged: (v) => setState(() => category = v ?? ''),
            decoration: const InputDecoration(labelText: 'Category'),
          ),

          const SizedBox(height: 12),
          // Rating slider
          const Text('Minimum Rating'),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: minRating,
                  min: 0,
                  max: 5,
                  divisions: 50,
                  label: minRating.toStringAsFixed(1),
                  onChanged: (v) => setState(
                    () => minRating = double.parse(v.toStringAsFixed(1)),
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  '${minRating.toStringAsFixed(1)} ★',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Year fields
          const Text('Publish Year Range'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: fromYearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'From Year'),
                  onChanged: (v) => setState(
                    () => fromYear = v.isEmpty ? null : int.tryParse(v),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: toYearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'To Year'),
                  onChanged: (v) => setState(
                    () => toYear = v.isEmpty ? null : int.tryParse(v),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Sorting
          Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'title', label: Text('Title')),
                    ButtonSegment(value: 'rating', label: Text('Rating')),
                  ],
                  selected: {sortBy},
                  onSelectionChanged: (s) => setState(() => sortBy = s.first),
                ),
              ),
              // Descending toggle button
              const SizedBox(width: 12),
              FilterChip(
                label: Text(descending ? 'Descending' : 'Ascending'),
                selected: descending,
                onSelected: (v) => setState(() => descending = v),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // APPLY: Update the global Riverpod state with the new local values
                filterNotifier
                  ..setCategory(category)
                  ..setMinRating(minRating)
                  ..setSortBy(sortBy)
                  ..setDescending(descending)
                  ..setFromYear(fromYear)
                  ..setToYear(toYear);

                // Close the bottom sheet
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
