import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_app/providers/filter_provider.dart';
import 'package:library_app/providers/book_provider.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late TextEditingController fromYearController;
  late TextEditingController toYearController;

  // Local copy of filter state
  late FilterState tempFilter;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(filterProvider);
    tempFilter = filter;

    fromYearController = TextEditingController(
      text: tempFilter.fromYear?.toString() ?? '',
    );
    toYearController = TextEditingController(
      text: tempFilter.toYear?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    fromYearController.dispose();
    toYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(bookListProvider);

    // Compute categories dynamically from books
    final categories = booksAsync.when(
      data: (books) => books.map((b) => b.Category).toSet().toList()..sort(),
      loading: () => <String>[],
      error: (_, __) => <String>[],
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 12),

          // CATEGORY DROPDOWN
          DropdownButtonFormField<String>(
            value: tempFilter.category.isEmpty ? '' : tempFilter.category,
            items: [
              const DropdownMenuItem(value: '', child: Text('Any')),
              ...categories.map(
                (c) => DropdownMenuItem(value: c, child: Text(c)),
              ),
            ],
            onChanged: (v) {
              setState(() {
                tempFilter = tempFilter.copyWith(category: v ?? '');
              });
            },
            decoration: const InputDecoration(labelText: 'Category'),
          ),

          const SizedBox(height: 12),

          // RATING SLIDER
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: tempFilter.minRating,
                  min: 0,
                  max: 5,
                  divisions: 50,
                  label: tempFilter.minRating.toStringAsFixed(1),
                  onChanged: (v) {
                    setState(() {
                      tempFilter = tempFilter.copyWith(
                        minRating: double.parse(v.toStringAsFixed(1)),
                      );
                    });
                  },
                ),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  '${tempFilter.minRating.toStringAsFixed(1)} ★',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // YEAR FIELDS
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: fromYearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'From Year'),
                  onChanged: (v) {
                    setState(() {
                      tempFilter = tempFilter.copyWith(
                        fromYear: v.isEmpty ? null : int.tryParse(v),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: toYearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'To Year'),
                  onChanged: (v) {
                    setState(() {
                      tempFilter = tempFilter.copyWith(
                        toYear: v.isEmpty ? null : int.tryParse(v),
                      );
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // SORTING
          Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'title', label: Text('Title')),
                    ButtonSegment(value: 'rating', label: Text('Rating')),
                  ],
                  selected: {tempFilter.sortBy},
                  onSelectionChanged: (s) {
                    setState(() {
                      tempFilter = tempFilter.copyWith(sortBy: s.first);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: Text(tempFilter.descending ? 'Descending' : 'Ascending'),
                selected: tempFilter.descending,
                onSelected: (v) {
                  setState(() {
                    tempFilter = tempFilter.copyWith(descending: v);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // APPLY BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(filterProvider.notifier).state = tempFilter;
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
