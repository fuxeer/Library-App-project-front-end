import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'library',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6D28D9), //بنفسجي انيق
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Book {
  final String title, author, category;
  final double rating;
  final int year;

  const Book({
    required this.title,
    required this.author,
    required this.rating,
    required this.category,
    required this.year,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final allBooks = const <Book>[
    Book(
      title: 'Are We Alone?',
      author: 'Group of People',
      rating: 4.3,
      category: 'Science',
      year: 2019,
    ),
    Book(
      title: 'Clean Code',
      author: 'Robert C. Martin',
      rating: 4.8,
      category: 'Programming',
      year: 2008,
    ),
    Book(
      title: 'Flutter in Action',
      author: 'Eric Windmill',
      rating: 4.6,
      category: 'Programming',
      year: 2020,
    ),
    Book(
      title: 'Design Patterns',
      author: 'GoF',
      rating: 4.7,
      category: 'Programming',
      year: 1994,
    ),
    Book(
      title: 'The Pragmatic Programmer',
      author: 'Andrew Hunt',
      rating: 4.9,
      category: 'Programming',
      year: 1999,
    ),
    Book(
      title: 'Atomic Habits',
      author: 'James Clear',
      rating: 4.5,
      category: 'Self-Help',
      year: 2018,
    ),
    Book(
      title: 'Deep Work',
      author: 'Cal Newport',
      rating: 4.4,
      category: 'Productivity',
      year: 2016,
    ),
    Book(
      title: 'Clean Architecture',
      author: 'Robert C. Martin',
      rating: 4.7,
      category: 'Programming',
      year: 2017,
    ),
    Book(
      title: 'The Art of Computer Programming',
      author: 'Donald Knuth',
      rating: 4.9,
      category: 'Programming',
      year: 1968,
    ),
    Book(
      title: 'Think Like a Monk',
      author: 'Jay Shetty',
      rating: 4.2,
      category: 'Self-Help',
      year: 2020,
    ),
  ];

  String query = '';
  String category = '';
  double minRating = 0.0;
  String sortBy = 'title';
  bool descending = false;

  List<Book> get _filtered {
    final q = query.toLowerCase();
    final list = allBooks.where((b) {
      final matchQ =
          b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.year.toString().contains(q);
      final matchC = category.isEmpty ? true : b.category == category;
      final matchR = b.rating >= minRating;
      return matchQ && matchC && matchR;
    }).toList();

    list.sort((a, b) {
      int cmp = sortBy == 'rating'
          ? a.rating.compareTo(b.rating)
          : a.title.toLowerCase().compareTo(b.title.toLowerCase());
      return descending ? -cmp : cmp;
    });
    return list;
  }

  void _openFilter() async {
    final categories = <String>{...allBooks.map((b) => b.category)}.toList()
      ..sort();
    final result = await showModalBottomSheet<_FiltersResult>(
      context: context,
      useSafeArea: true,
      builder: (_) => _FilterSheet(
        categories: categories,
        initial: _FiltersResult(category, minRating, sortBy, descending),
      ),
    );
    if (result != null) {
      setState(() {
        category = result.category;
        minRating = result.minRating;
        sortBy = result.sortBy;
        descending = result.descending;
      });
    }
  }

  void _resetFilters() => setState(() {
    category = '';
    minRating = 0.0;
    sortBy = 'title';
    descending = false;
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final books = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(30),
            child: const Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child: Icon(Icons.menu),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: const Icon(Icons.person),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Mohammed',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                hintText: 'Search for book',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _openFilter,
                  icon: const Icon(Icons.tune),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (category.isNotEmpty)
                  _chip(category, onClear: () => setState(() => category = '')),
                _chip('≥ ${minRating.toStringAsFixed(1)} ★'),
                _chip(
                  (sortBy == 'rating' ? 'Sort: rating' : 'Sort: title') +
                      (descending ? ' ↓' : ' ↑'),
                ),
                if (category.isNotEmpty ||
                    minRating > 0 ||
                    sortBy != 'title' ||
                    descending)
                  ActionChip(
                    label: const Text('Reset'),
                    onPressed: _resetFilters,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (books.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No books found 😢',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...books.map(
                (b) => InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: _BookCard(book: b),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, {VoidCallback? onClear}) {
    return Chip(
      label: Text(text),
      onDeleted: onClear,
      deleteIcon: onClear == null ? null : const Icon(Icons.close),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 56,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Author: ${book.author}'),
                Text(
                  'Category: ${book.category}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Published: ${book.year}',
                  style: const TextStyle(color: Colors.grey),
                ), // 👈 ADD THIS
              ],
            ),
          ),
          Text('${book.rating} / 5'),
        ],
      ),
    );
  }
}

class _FiltersResult {
  final String category;
  final double minRating;
  final String sortBy;
  final bool descending;
  const _FiltersResult(
    this.category,
    this.minRating,
    this.sortBy,
    this.descending,
  );
}

class _FilterSheet extends StatefulWidget {
  final List<String> categories;
  final _FiltersResult initial;
  const _FilterSheet({required this.categories, required this.initial});
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String category = '';
  double minRating = 0;
  String sortBy = 'title';
  bool descending = false;

  @override
  void initState() {
    super.initState();
    category = widget.initial.category;
    minRating = widget.initial.minRating;
    sortBy = widget.initial.sortBy;
    descending = widget.initial.descending;
  }

  @override
  Widget build(BuildContext context) {
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

          // Dropdown for category filter
          DropdownButtonFormField<String>(
            value: category.isEmpty ? '' : category,
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
              onPressed: () => Navigator.pop(
                context,
                _FiltersResult(category, minRating, sortBy, descending),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
