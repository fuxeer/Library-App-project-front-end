import 'package:flutter/material.dart';
import 'model/Book.dart';

class AdminBookCard extends StatelessWidget {
  final Book book;
  

  const AdminBookCard({
    super.key,
    required this.book,
    
  });

  @override
  Widget build(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Stack(
      children: [

        // CARD 
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.Title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Author: ${book.Author}"),
              SizedBox(height: 2,),
              Text("Category: ${book.Category}"),
              SizedBox(height: 2,),
              Text("Rating: ${book.Rating} ★"),
              SizedBox(height: 2,),
              Text("Year: ${book.PublishYear}"),
            ],
          ),
        ),

        // NEW: DELETE BUTTON 
        Positioned(
          right: 12,
          top: 12,
          child: IconButton(
            onPressed: () => _confirmDelete(context),
            icon: Icon(Icons.delete, color: cs.primary),
            style: IconButton.styleFrom(
              backgroundColor:cs.primaryContainer.withOpacity(.4),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),

        // NEW: EDIT BUTTON 
        Positioned(
          right: 12,
          bottom: 12,
          child: IconButton(
            onPressed: () => _openEditDialog(context),
            icon: Icon(Icons.edit, color: cs.primary),
            style: IconButton.styleFrom(
              backgroundColor: cs.primaryContainer.withOpacity(.4),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    ),
  );
}

  // NEW: when pressing the edit button
  void _openEditDialog(BuildContext context) {
  final titleCtrl = TextEditingController(text: book.Title);
  final authorCtrl = TextEditingController(text: book.Author);
  final categoryCtrl = TextEditingController(text: book.Category);
  final ratingCtrl = TextEditingController(text: book.Rating.toString());
  final yearCtrl = TextEditingController(text: book.PublishYear.toString());
  final publisherCtrl = TextEditingController(text: book.Publisher ,);
  final descriptionCtrl = TextEditingController(text: book.Description ,);

  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(   
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Edit the Book",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _editField("Title", titleCtrl, maxLines: 1),
              const SizedBox(height: 20),

              _editField("Author", authorCtrl, maxLines: 1),
              const SizedBox(height: 20),

              _editField("Category", categoryCtrl, maxLines: 1),
              const SizedBox(height: 20),

              _editField("Rating", ratingCtrl,
                keyboard: TextInputType.number, maxLines:1),
              const SizedBox(height: 20),

              _editField("Year", yearCtrl,
                keyboard: TextInputType.number, maxLines: 1),
              const SizedBox(height: 20),

              _editField("Description", descriptionCtrl,
                maxLines: 3),
              const SizedBox(height: 20),

              _editField("publisher", publisherCtrl,
                maxLines: 3),
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
                      // No logic yet
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}


 //NEW: for editing the books (not functional)
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

//NEW: for the delete popup before deletion
void _confirmDelete(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        "Delete Book",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      content: const Text(
        "Are you sure you want to delete this book?",
        style: TextStyle(fontSize: 16),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(fontSize: 15),
          ),
        ),

        ElevatedButton(
          onPressed: () {
            // No functionality for now
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

}
