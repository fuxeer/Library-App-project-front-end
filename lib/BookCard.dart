//bookcard
import 'package:flutter/material.dart';
import '../model/Book.dart'; 

// for building the book card ui
class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

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
                  book.Title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Author: ${book.Author}'),
                Text(
                  'Category: ${book.Category}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Published: ${book.PublishYear}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text('${book.Rating} / 5'),
        ],
      ),
    );
  }
}