class BookingRange {
  final DateTime start;
  final DateTime end;

  BookingRange({required this.start, required this.end});

  factory BookingRange.fromJson(Map<String, dynamic> json) {
    return BookingRange(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }

  get startDate => null;

  get endDate => null;

  // Checks if a given date is inside this range
  bool contains(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  // Static helper to check availability against multiple booked ranges
  static bool isAvailable(DateTime date, List<BookingRange> bookedRanges) {
    for (var range in bookedRanges) {
      if (range.contains(date)) return false;
    }
    return true;
  }
}
