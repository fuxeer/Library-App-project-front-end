//mainpage
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:library_app/filter.dart';
import 'model/Book.dart';
import 'model/CurrentUser.dart';
import 'package:http/http.dart' as http;
import 'filter.dart';
import 'BookCard.dart';

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
        colorSchemeSeed: const Color(0xFF6D28D9),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Book> allBooks = [];
  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await getBooks();

    setState(() {
      allBooks = books;
    });
  }

  Future<List<Book>> getBooks() async {
    // This function would fetch data from an API or database]
    final url = Uri.parse("https://localhost:7145/api/Books");

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final books = jsonData.map((item) => Book.fromJson(item)).toList();
        return books;
      }
    } catch (e) {
      print(e);
    }

    return [];
  }

  // Filters
  String query = '';
  String category = '';
  double minRating = 0.0;
  String sortBy = 'title';
  bool descending = false;

  // YEAR RANGE FILTER
  int? fromYear;
  int? toYear;

  // Filtered book list
  List<Book> get _filtered {
  return BookFilter.apply(
    books: allBooks,
    query: query,
    category: category,
    minRating: minRating,
    sortBy: sortBy,
    descending: descending,
  );
}
//NEW:added the drawer to put functionality in the menu icon
Widget _buildMenuDrawer() {
  return Drawer(
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(13),
        children: [

          const Text(
            "Menu",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text("Reservations"),
            onTap: () {}
            ,
          ),

          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text("Browse Books"),
            onTap: () {}
            ,
          ),

          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Support"),
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}

  // Open filter bottom sheet
  void _openFilter() async {
    final categories = <String>{...allBooks.map((b) => b.Category)}.toList()
      ..sort();

    final result = await showModalBottomSheet<_FiltersResult>(
      context: context,
      useSafeArea: true,
      builder: (_) => _FilterSheet(
        categories: categories,
        initial: _FiltersResult(
          category,
          minRating,
          sortBy,
          descending,
          fromYear,
          toYear,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        category = result.category;
        minRating = result.minRating;
        sortBy = result.sortBy;
        descending = result.descending;
        fromYear = result.fromYear;
        toYear = result.toYear;
      });
    }
  }

  // Reset filters (reset button)
  void _resetFilters() => setState(() {
    category = '';
    minRating = 0.0;
    sortBy = 'title';
    descending = false;
    fromYear = null;
    toYear = null;
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final books = _filtered;
    // menu (placeholder)
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        // NEW: added functionality to the menu icon button
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
              );
            }
          )
        ],
      ),
       endDrawer: _buildMenuDrawer(),
      // the profile
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
                Text(
                  currentUser?.name ?? 'No name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // search textfield + filter button
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
            // helper method for active filter
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (category.isNotEmpty)
                  _chip(category, onClear: () => setState(() => category = '')),

                _chip('≥ ${minRating.toStringAsFixed(1)} ★'),

                if (fromYear != null || toYear != null)
                  _chip(
                    'Year: ${fromYear ?? "Any"} → ${toYear ?? "Any"}',
                    onClear: () => setState(() {
                      fromYear = null;
                      toYear = null;
                    }),
                  ),

                _chip(
                  (sortBy == 'rating' ? 'Sort: rating' : 'Sort: title') +
                      (descending ? ' ↓' : ' ↑'),
                ),
                // reset button
                if (category.isNotEmpty ||
                    minRating > 0 ||
                    sortBy != 'title' ||
                    descending ||
                    fromYear != null ||
                    toYear != null)
                  ActionChip(
                    label: const Text('Reset'),
                    onPressed: _resetFilters,
                  ),
              ],
            ),

            const SizedBox(height: 8),
            // the book is not Available
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
              ...books.map((b) => BookCard(book: b)),
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


// Filter result model
class _FiltersResult {
  final String category;
  final double minRating;
  final String sortBy;
  final bool descending;
  final int? fromYear;
  final int? toYear;

  const _FiltersResult(
    this.category,
    this.minRating,
    this.sortBy,
    this.descending,
    this.fromYear,
    this.toYear,
  );
}

// FILTER SHEET
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

  int? fromYear;
  int? toYear;

  // controller for the years textfield
  TextEditingController? fromYearController;
  TextEditingController? toYearController;

  // state update
  @override
  void initState() {
    super.initState();

    category = widget.initial.category;
    minRating = widget.initial.minRating;
    sortBy = widget.initial.sortBy;
    descending = widget.initial.descending;

    fromYear = widget.initial.fromYear;
    toYear = widget.initial.toYear;

    fromYearController = TextEditingController(
      text: fromYear?.toString() ?? '',
    );

    toYearController = TextEditingController(text: toYear?.toString() ?? '');
  }

  // building the filter dropdown sheet
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
          // building the category dropdown menu
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
          // building the rating slider
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

          // building the year fields
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: fromYearController!,
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
                  controller: toYearController!,
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
          // building the segmented button for sorting by title/rating
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
              //building the descending toggle button
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
                Navigator.pop(
                  context,
                  _FiltersResult(
                    category,
                    minRating,
                    sortBy,
                    descending,
                    fromYear,
                    toYear,
                  ),
                );
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
