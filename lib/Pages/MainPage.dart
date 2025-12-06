import 'dart:convert';
import 'dart:typed_data';
import 'package:library_app/BookCard.dart';
import 'package:library_app/providers/CurrentUser_provider.dart';
import 'package:library_app/providers/book_provider.dart';
import 'package:library_app/providers/filter_provider.dart';
import 'package:library_app/widgets/Filtersheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:library_app/model/Book.dart';
import 'package:library_app/History.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library',
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

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Uint8List? profilePicBytes;

  Future<Uint8List?> pickImageBytes() async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );
        if (result != null && result.files.isNotEmpty)
          return result.files.first.bytes!;
        return null;
      }

      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) return await picked.readAsBytes();
      return null;
    } catch (e) {
      print("Image pick error: $e");
      return null;
    }
  }

  void _openProfileDialog() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Temporary variables for edits
    String tempName = user.name ?? '';
    String tempEmail = user.email ?? '';
    int? tempPhone = user.phoneNo;
    String tempAddress = user.address ?? '';

    // Track which fields are in edit mode
    Map<String, bool> editMode = {
      'name': false,
      'email': false,
      'phone': false,
      'address': false,
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.purple[100],
                    child: const Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 20),

                  _editableField(
                    label: "Name",
                    value: tempName,
                    isEditing: editMode['name']!,
                    onEditPressed: () =>
                        setDialogState(() => editMode['name'] = true),
                    onChanged: (v) => tempName = v,
                  ),
                  const SizedBox(height: 16),

                  _editableField(
                    label: "Email",
                    value: tempEmail,
                    isEditing: editMode['email']!,
                    onEditPressed: () =>
                        setDialogState(() => editMode['email'] = true),
                    onChanged: (v) => tempEmail = v,
                  ),
                  const SizedBox(height: 16),

                  _editableField(
                    label: "Phone",
                    value: tempPhone?.toString() ?? '',
                    isEditing: editMode['phone']!,
                    keyboardType: TextInputType.number,
                    onEditPressed: () =>
                        setDialogState(() => editMode['phone'] = true),
                    onChanged: (v) => tempPhone = int.tryParse(v),
                  ),
                  const SizedBox(height: 16),

                  _editableField(
                    label: "Address",
                    value: tempAddress,
                    isEditing: editMode['address']!,
                    onEditPressed: () =>
                        setDialogState(() => editMode['address'] = true),
                    onChanged: (v) => tempAddress = v,
                  ),

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
                        onPressed: () async {
                          final user = ref.read(currentUserProvider);
                          if (user == null) return;

                          bool success = await ref
                              .read(userRepositoryProvider)
                              .updateUserPartial(
                                userId: user.userID!,
                                name: tempName,
                                email: tempEmail,
                                phoneNo: tempPhone?.toString(),
                                address: tempAddress,
                              );

                          if (success) {
                            // Update local state only if backend update succeeded
                            ref
                                .read(currentUserProvider.notifier)
                                .update(
                                  name: tempName,
                                  email: tempEmail,
                                  phoneNo: tempPhone,
                                  address: tempAddress,
                                );

                            Navigator.pop(context);
                          } else {
                            // Show error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to update user"),
                              ),
                            );
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper widget: shows text initially, becomes TextField when edit is pressed
  Widget _editableField({
    required String label,
    required String value,
    required bool isEditing,
    required VoidCallback onEditPressed,
    required void Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    if (isEditing) {
      final controller = TextEditingController(text: value);
      return TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: onChanged,
        keyboardType: keyboardType,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: $value', style: const TextStyle(fontSize: 16)),
        CircleAvatar(
          radius: 16,
          child: IconButton(
            icon: const Icon(Icons.edit, size: 16),
            onPressed: onEditPressed,
          ),
        ),
      ],
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller, {
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  void _openFilter() {
    final categories = ref
        .read(bookListProvider)
        .maybeWhen(
          data: (books) =>
              <String>{...books.map((b) => b.Category)}.toList()..sort(),
          orElse: () => [],
        );

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (_) => const FilterSheet(),
    );
  }

  void _resetFilters() => ref.read(filterProvider.notifier).resetFilter();

  @override
  Widget build(BuildContext context) {
    final filteredBooks = ref.watch(filteredBooksProvider);
    final filter = ref.watch(filterProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 140,
        leading: InkWell(
          onTap: _openProfileDialog,
          child: Row(
            children: [
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 16,
                backgroundImage: profilePicBytes != null
                    ? MemoryImage(profilePicBytes!)
                    : null,
                child: profilePicBytes == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 8),
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildMenuDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => ref.read(filterProvider.notifier).setQuery(v),
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
              if (filter.category.isNotEmpty)
                _chip(
                  filter.category,
                  onClear: () =>
                      ref.read(filterProvider.notifier).setCategory(''),
                ),
              _chip('≥ ${filter.minRating.toStringAsFixed(1)} ★'),
              if (filter.fromYear != null || filter.toYear != null)
                _chip(
                  'Year: ${filter.fromYear ?? "Any"} → ${filter.toYear ?? "Any"}',
                  onClear: () {
                    ref.read(filterProvider.notifier).setFromYear(null);
                    ref.read(filterProvider.notifier).setToYear(null);
                  },
                ),
              _chip(
                (filter.sortBy == 'rating' ? 'Sort: rating' : 'Sort: title') +
                    (filter.descending ? ' ↓' : ' ↑'),
              ),
              if (filter.category.isNotEmpty ||
                  filter.minRating > 0 ||
                  filter.sortBy != 'title' ||
                  filter.descending ||
                  filter.fromYear != null ||
                  filter.toYear != null)
                ActionChip(
                  label: const Text('Reset'),
                  onPressed: _resetFilters,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (filteredBooks.isEmpty)
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
            ...filteredBooks.map((b) => BookCard(book: b)),
        ],
      ),
    );
  }

  Widget _chip(String text, {VoidCallback? onClear}) {
    return Chip(
      label: Text(text),
      onDeleted: onClear != null ? onClear : null,
      deleteIcon: onClear != null ? const Icon(Icons.close) : null,
    );
  }

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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserHistoryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text("Browse Books"),
              onTap: () {},
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
}
