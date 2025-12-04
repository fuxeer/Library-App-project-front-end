import 'package:riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  final String query;
  final String category;
  final double minRating;
  final String sortBy;
  final bool descending;
  final int? fromYear;
  final int? toYear;

  const FilterState({
    this.query = '',
    this.category = '',
    this.minRating = 0.0,
    this.sortBy = 'title',
    this.descending = false,
    this.fromYear,
    this.toYear,
  });

  FilterState copyWith({
    String? query,
    String? category,
    double? minRating,
    String? sortBy,
    bool? descending,
    int? fromYear,
    int? toYear,
  }) => FilterState(
    query: query ?? this.query,
    category: category ?? this.category,
    minRating: minRating ?? this.minRating,
    sortBy: sortBy ?? this.sortBy,
    descending: descending ?? this.descending,
    fromYear: fromYear ?? this.fromYear,
    toYear: toYear ?? this.toYear,
  );
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setMinRating(double minRating) {
    state = state.copyWith(minRating: minRating);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setDescending(bool descending) {
    state = state.copyWith(descending: descending);
  }

  void setFromYear(int? fromYear) {
    state = state.copyWith(fromYear: fromYear);
  }

  void setToYear(int? toYear) {
    state = state.copyWith(toYear: toYear);
  }

  void resetFilter() {
    state = const FilterState();
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((
  ref,
) {
  return FilterNotifier();
});
