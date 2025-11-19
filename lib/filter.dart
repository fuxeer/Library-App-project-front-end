//filter
import 'package:flutter/material.dart';
import 'model/Book.dart';
import '../MainPage.dart';

class BookFilter{
  static List<Book> apply({
    required List<Book> books,
    required String query,
    required String category,
    required double minRating,
    required String sortBy,
    required bool descending,
  }) {
    final q = query.toLowerCase();

    final list = books.where((b) {
      final matchQ =
          b.Title.toLowerCase().contains(q) ||
          b.Author.toLowerCase().contains(q) ||
          b.PublishYear.toString().contains(q);

      final matchC = category.isEmpty ? true : b.Category == category;

      final matchR = b.Rating >= minRating;

      return matchQ && matchC && matchR;
    }).toList();

    // sorting
    list.sort((a, b) {
      int cmp = sortBy == 'rating'
          ? a.Rating.compareTo(b.Rating)
          : a.Title.toLowerCase().compareTo(b.Title.toLowerCase());

      return descending ? -cmp : cmp;
    });

    return list;
  }
}
