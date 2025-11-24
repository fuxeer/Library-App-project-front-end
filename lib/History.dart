import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book History',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Set the primary color for a clean look
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const HistoryScreen(),
    );
  }
}

// --- Data Model for History Items ---
class HistoryItem {
  final String bookName;
  final double rating;
  final String rentStatus;
  final String orderId; // Keeping as String for simplicity in display, but treated as numeric for search

  const HistoryItem({
    required this.bookName,
    required this.rating,
    required this.rentStatus,
    required this.orderId,
  });
}

// --- The Main Screen Widget (StatefulWidget for search handler) ---
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // State for the search query
  String _searchQuery = '';

  // Mock data with numeric Order IDs (as strings)
  List<HistoryItem> get mockHistoryData => const [
    HistoryItem(
      bookName: 'The Great Gatsby',
      rating: 4.5,
      rentStatus: 'Returned',
      orderId: '001',
    ),
    HistoryItem(
      bookName: 'To Kill a Mockingbird',
      rating: 5.0,
      rentStatus: 'Active',
      orderId: '002',
    ),
    HistoryItem(
      bookName: 'The Hobbit',
      rating: 4.8,
      rentStatus: 'Returned',
      orderId: '004',
    ),
    HistoryItem(
      bookName: '1984',
      rating: 4.2,
      rentStatus: 'Pending',
      orderId: '003',
    ),
  ];

  // --- HANDLER METHODS FOR DIALOGS ---

  void _showRateDialog(BuildContext context, HistoryItem item) {
    double tempRating = 0; // Local state for the selected rating in the dialog

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Rate "${item.bookName}"'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select your rating:'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starRating = index + 1;
                      return IconButton(
                        icon: Icon(
                          starRating <= tempRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            tempRating = starRating.toDouble();
                          });
                        },
                      );
                    }),
                  ),
                  if (tempRating > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text('Selected: ${tempRating.toStringAsFixed(1)}/5'),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: tempRating > 0
                      ? () {
                          debugPrint('Submitting Rating: ${item.bookName} rated $tempRating/5');
                          // In a real app, you would submit this rating to a database here.
                          Navigator.of(context).pop();
                        }
                      : null, // Disable button if no rating is selected
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCommentDialog(BuildContext context, HistoryItem item) {
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Write a Review for "${item.bookName}"'),
          content: TextField(
            controller: reviewController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter your review here...',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final reviewText = reviewController.text.trim();
                if (reviewText.isNotEmpty) {
                  debugPrint('Submitting Review for ${item.bookName}: "$reviewText"');
                  // In a real app, you would submit this review to a database here.
                  Navigator.of(context).pop();
                } else {
                  // Optional: Show a small toast/snackbar that the field is empty
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply filtering logic here
    final filteredHistory = mockHistoryData.where((item) {
      // Check if the orderId contains the search query (case-insensitive)
      return item.orderId.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
      ),
      // --- WRAPPED CONTENT FOR PHONE SIZE EXCLUSIVITY ---
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSearchBar(),
              ),
              Expanded(
                child: filteredHistory.isEmpty
                    ? const Center(child: Text("No orders found."))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final item = filteredHistory[index];
                          return HistoryCard(
                            item: item,
                            onComment: (item) => _showCommentDialog(context, item),
                            onRate: (item) => _showRateDialog(context, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // --------------------------------------------------
    );
  }

  // Helper method to build the Search Bar widget
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        keyboardType: TextInputType.number, // Ensure numeric keyboard pops up
        onChanged: (value) {
          setState(() {
            // Update the state and trigger a rebuild to filter the list
            _searchQuery = value.trim();
          });
        },
        decoration: const InputDecoration(
          hintText: 'Search by Order ID',
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide.none, // Hide default border
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }
}

// --- Custom History Card Widget ---
class HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final Function(HistoryItem) onComment;
  final Function(HistoryItem) onRate;

  const HistoryCard({
    super.key,
    required this.item,
    required this.onComment,
    required this.onRate,
  });

  // Check if the current book status allows commenting/rating
  bool get _isReviewable {
    return item.rentStatus == 'Active' || item.rentStatus == 'Returned';
  }

  // Helper function to build a consistent info row (e.g., Book Name, Rating, Status)
  Widget _buildInfoRow(String title, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 100, // Fixed width for the title column for alignment
            child: Text(
              '$title ',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          Expanded(
            child: valueWidget,
          ),
        ],
      ),
    );
  }

  // Helper to build the original status chip
  Widget _buildRentStatusChip() {
    Color chipColor;
    Color textColor;

    // Matching the original visual style
    switch (item.rentStatus) {
      case 'Returned':
        chipColor = const Color(0xFFE0E0E0); // Light grey/green
        textColor = Colors.black87;
        break;
      case 'Active':
        chipColor = const Color(0xFFC8E6C9); // Bright green
        textColor = const Color(0xFF4CAF50); // Darker green text
        break;
      case 'Pending':
        chipColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      default:
        chipColor = Colors.grey.shade300;
        textColor = Colors.black87;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        item.rentStatus,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the color of the disabled icons
    final disabledColor = Colors.grey.shade400;

    return Card(
      elevation: 1, // Reduced elevation for a cleaner look
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 1. Book Name Row
                _buildInfoRow(
                  'Book Name',
                  Text(
                    item.bookName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),

                // 2. Rating Row
                _buildInfoRow(
                  'Rating',
                  Row(
                    children: <Widget>[
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        // Match the exact format X.X/5
                        '${item.rating.toStringAsFixed(1)}/5',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                // 3. Rent Status Row (Using the chip)
                _buildInfoRow(
                  'Rent Status',
                  _buildRentStatusChip(),
                ),

                // --- Divider and Order ID at the bottom ---
                const Divider(height: 16, thickness: 1, color: Colors.black12),

                // 4. Order ID
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      const Text(
                        'Order ID: ',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      Text(
                        item.orderId,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Floating Action Icons on the right side of the card
          Positioned(
            top: 10,
            right: 5,
            child: Column(
              children: [
                // Chat/Message Icon (Comment Button)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: _isReviewable ? Colors.blueAccent : disabledColor,
                    size: 24,
                  ),
                  onPressed: _isReviewable ? () => onComment(item) : null, // Disable if not reviewable
                ),
                const SizedBox(height: 12),
                // Star/Rating Icon (Rate Button)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.star_border, // Use border icon to match the original screenshot
                    color: _isReviewable ? Colors.amber : disabledColor,
                    size: 24,
                  ),
                  onPressed: _isReviewable ? () => onRate(item) : null, // Disable if not reviewable
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}