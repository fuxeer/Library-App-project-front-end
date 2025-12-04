import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_app/providers/filter_provider.dart';
import 'package:library_app/providers/book_provider.dart'; // your bookListProvider

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late TextEditingController fromYearController;
  late TextEditingController toYearController;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(filterProvider);
    fromYearController = TextEditingController(
      text: filter.fromYear?.toString() ?? '',
    );
    toYearController = TextEditingController(
      text: filter.toYear?.toString() ?? '',
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
    final filter = ref.watch(filterProvider);
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
            value: filter.category.isEmpty ? '' : filter.category,
            items: [
              const DropdownMenuItem(value: '', child: Text('Any')),
              ...categories.map(
                (c) => DropdownMenuItem(value: c, child: Text(c)),
              ),
            ],
            onChanged: (v) =>
                ref.read(filterProvider.notifier).setCategory(v ?? ''),
            decoration: const InputDecoration(labelText: 'Category'),
          ),

          const SizedBox(height: 12),

          // RATING SLIDER
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: filter.minRating,
                  min: 0,
                  max: 5,
                  divisions: 50,
                  label: filter.minRating.toStringAsFixed(1),
                  onChanged: (v) => ref
                      .read(filterProvider.notifier)
                      .setMinRating(double.parse(v.toStringAsFixed(1))),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  '${filter.minRating.toStringAsFixed(1)} ★',
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
                  onChanged: (v) => ref
                      .read(filterProvider.notifier)
                      .setFromYear(v.isEmpty ? null : int.tryParse(v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: toYearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'To Year'),
                  onChanged: (v) => ref
                      .read(filterProvider.notifier)
                      .setToYear(v.isEmpty ? null : int.tryParse(v)),
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
                  selected: {filter.sortBy},
                  onSelectionChanged: (s) =>
                      ref.read(filterProvider.notifier).setSortBy(s.first),
                ),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: Text(filter.descending ? 'Descending' : 'Ascending'),
                selected: filter.descending,
                onSelected: (v) =>
                    ref.read(filterProvider.notifier).setDescending(v),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // APPLY BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
