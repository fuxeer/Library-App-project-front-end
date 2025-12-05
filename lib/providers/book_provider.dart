import 'package:library_app/CalenderTest.dart';
import 'package:riverpod/riverpod.dart';
import 'package:library_app/repositroy/BookRepository.dart';
import '../model/Book.dart';
import 'filter_provider.dart';
import 'package:library_app/model/BookingRange.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

final bookListProvider = FutureProvider<List<Book>>((ref) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return bookRepository.getAllBooks();
});

final bookedRangesProvider = FutureProvider.family<List<BookingRange>, int>((
  ref,
  bookId,
) async {
  final repo = ref.watch(bookRepositoryProvider);
  return repo.getBookedRanges(bookId);
});

final filteredBooksProvider = Provider<List<Book>>((ref) {
  final booksAsync = ref.watch(bookListProvider);
  final filter = ref.watch(filterProvider);

  return booksAsync.when(
    data: (books) {
      var result = books;

      // QUERY
      if (filter.query.isNotEmpty) {
        result = result
            .where(
              (b) => b.Title.toLowerCase().contains(filter.query.toLowerCase()),
            )
            .toList();
      }

      // CATEGORY
      if (filter.category.isNotEmpty) {
        result = result.where((b) => b.Category == filter.category).toList();
      }

      // YEAR
      if (filter.fromYear != null) {
        result = result
            .where((b) => b.PublishYear >= filter.fromYear!)
            .toList();
      }
      if (filter.toYear != null) {
        result = result.where((b) => b.PublishYear <= filter.toYear!).toList();
      }

      // RATING
      result = result.where((b) => b.Rating >= filter.minRating).toList();

      // SORTING
      if (filter.sortBy == 'rating') {
        result.sort((a, b) => a.Rating.compareTo(b.Rating));
      } else {
        result.sort((a, b) => a.Title.compareTo(b.Title));
      }

      if (filter.descending) result = result.reversed.toList();

      return result;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
