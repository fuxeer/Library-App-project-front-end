//mainpage
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:library_app/filter.dart';
import 'package:library_app/model/CurrentUser.dart';
import 'model/Book.dart';
import 'package:http/http.dart' as http;
import 'AdminBC.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';






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
      home: const AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<Book> allBooks = [];
  @override
  void initState() {
    super.initState();
    _loadBooks();
  }


 Uint8List? profilePicBytes;   
 Uint8List? tempPicBytes;
         

//NEW: for picking the pic 
Future<Uint8List?> pickImageBytes() async {
  try {
    // WEB + DESKTOP
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // MUST for byte data
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.bytes!;
      }
      return null;
    }

    // ANDROID / IOS
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      return await picked.readAsBytes(); // SAFE
    }
    return null;

  } catch (e) {
    print("Image pick error: $e");
    return null;
  }
}


  List<Book> getMockBooks() {
  return [
    Book(
      id: 1,
      Title: "Are We Alone?",
      Author: "Group of People",
      Category: "Science",
      Rating: 4.5,
      PublishYear: 2021, BookID: 3, Description: '', Publisher: '',
    ),
    Book(
      id: 2,
      Title: "The Lost Kingdom",
      Author: "Sarah Miller",
      Category: "Fantasy",
      Rating: 4.0,
      PublishYear: 2019, BookID: 2, Description: '', Publisher: '',
    ),
    Book(
      id: 3,
      Title: "Preeng in Dart",
      Author: "John Adams",
      Category: "Technology",
      Rating: 4.8,
      PublishYear: 2023, BookID: 1, Description: '', Publisher: '',
    ),
    Book(
      id: 3,
      Title: "Prrrerret",
      Author: "John Adams",
      Category: "Technology",
      Rating: 4.8,
      PublishYear: 2023, BookID: 1, Description: '', Publisher: '',
    ),
    Book(
      id: 3,
      Title: "weewqe",
      Author: "John Adams",
      Category: "Technology",
      Rating: 4.8,
      PublishYear: 2023, BookID: 1, Description: '', Publisher: '',
    ),
  ];
}
/*Future<void> _loadBooks() async { 
  final books = await getBooks(); 
  setState(() {
    allBooks = books; 
  }); 
}  */

  Future<void> _loadBooks() async {
  // USE MOCK BOOKS
  final books = getMockBooks();

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
 // NEW: for updating the profile info (just a placeholder)
 void _openProfileDialog() {
  Uint8List? tempPic = profilePicBytes; // current picture
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // PROFILE PIC AREA
                  InkWell(
                    onTap: () async {
                      Uint8List? picked = await pickImageBytes(); // pick image

                      if (picked != null) {
                        setDialogState(() {
                          tempPic = picked;   // update popup
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.purple[100],
                      backgroundImage:
                          tempPic != null ? MemoryImage(tempPic!) : null,
                      child: tempPic == null
                          ? const Icon(Icons.person, size: 50, color: Colors.black)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _editField("username", usernameCtrl, maxLines: 1),
                  const SizedBox(height: 20),

                  _editField("email", emailCtrl, maxLines: 1),
                  const SizedBox(height: 20),

                  _editField("phone no", phoneCtrl, maxLines: 1),
                  const SizedBox(height: 20),

                  _editField("address", addressCtrl, maxLines: 1),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // APPLY CHANGES HERE
                          setState(() {
                            profilePicBytes = tempPic;  // update app bar here
                          });

                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      );
    },
  );
}


  // NEW: added funtionality to the add book(+) button
 void _openAddDialog() {
   final titleController = TextEditingController();
  final authorController = TextEditingController();
  final categoryController = TextEditingController();
  final ratingController = TextEditingController();
  final yearController = TextEditingController();
  final publisherController = TextEditingController();
  final descriptionController = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add a Book",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _editField("Title", titleController, maxLines: 1),
            const SizedBox(height: 20),

            _editField("Author", authorController, maxLines: 1),
            const SizedBox(height: 20),

            _editField("Category", categoryController, maxLines: 1),
            const SizedBox(height: 20),

            _editField("Rating", ratingController, keyboard: TextInputType.number, maxLines: 1),
            const SizedBox(height: 20),

            _editField("Year", yearController, keyboard: TextInputType.number, maxLines: 1),
            const SizedBox(height: 20),

            _editField("publisher", publisherController, maxLines: 1),
            const SizedBox(height: 20),

            _editField("Description", descriptionController, maxLines: 3),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // No functionality yet 
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

 Widget _editField(
  String label,
  TextEditingController controller, {
  TextInputType keyboard = TextInputType.text, required int maxLines,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboard,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );
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
// puting functionality in the menu icon
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
            title: const Text("Customer Reservations"),
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
    final books = _filtered;
    // menu
    return Scaffold(
      //New: made the profile in the appbar
      appBar: AppBar(
        leadingWidth: 140, 
        leading: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _openProfileDialog,
          child: Row(
            children: [
              const SizedBox(width: 12),

            // Avatar
            CircleAvatar(
              radius: 16,
              backgroundImage: profilePicBytes != null
              ? MemoryImage(profilePicBytes!)
              : null,
              child: profilePicBytes == null ? Icon(Icons.person) : null,
            ),

            const SizedBox(width: 8),

            // Username
            Text(
              currentUser?.name ?? "No name",
              style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),


  actions: [
    //NEW: ADD BUTTON
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: _openAddDialog,
    ),

    // MENU BUTTON
    Builder(
      builder: (context) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        );
      },
    ),
  ],
),


       endDrawer: _buildMenuDrawer(),
      // the profile
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
              ...books.map((b) => AdminBookCard(book: b,))
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
