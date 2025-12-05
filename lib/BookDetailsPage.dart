import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/Book.dart';
import '../model/BookingRange.dart';
import '../repositroy/BookRepository.dart';
import 'package:table_calendar/table_calendar.dart';

class BookDetailsPage extends ConsumerStatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  ConsumerState<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends ConsumerState<BookDetailsPage> {
  List<BookingRange> availableRanges = [];
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableRanges();
  }

  Future<void> fetchAvailableRanges() async {
    final repo = BookRepository();
    final ranges = await repo.getBookedRanges(widget.book.BookID);
    setState(() {
      availableRanges = ranges;
      isLoading = false;
    });
  }

  bool isAvailable(DateTime date) {
    for (var range in availableRanges) {
      if (!date.isBefore(range.start) && !date.isAfter(range.end)) {
        return true; // date is available
      }
    }
    return false; // date is not selectable
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.Title)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book info
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.menu_book, size: 36),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.Title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Author: ${widget.book.Author}'),
                            Text('Category: ${widget.book.Category}'),
                            Text('Published: ${widget.book.PublishYear}'),
                            Text('Rating: ${widget.book.Rating} / 5'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.book.Description ?? "No description available",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Booking calendar
                  const Text(
                    "Select Booking Dates",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: startDate ?? DateTime.now(),
                    selectedDayPredicate: (day) {
                      if (startDate != null && endDate != null) {
                        return !day.isBefore(startDate!) &&
                            !day.isAfter(endDate!);
                      }
                      return day == startDate;
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isAvailable(selectedDay)) return;

                      setState(() {
                        if (startDate == null ||
                            (startDate != null && endDate != null)) {
                          startDate = selectedDay;
                          endDate = null;
                        } else if (startDate != null && endDate == null) {
                          if (selectedDay.isBefore(startDate!)) {
                            endDate = startDate;
                            startDate = selectedDay;
                          } else {
                            endDate = selectedDay;
                          }
                        }
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        if (!isAvailable(day)) {
                          return Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      rangeHighlightBuilder: (context, day, isWithinRange) {
                        if (isWithinRange) {
                          return Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(child: Text('${day.day}')),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selected range info
                  if (startDate != null)
                    Text(
                      endDate != null
                          ? 'Selected: ${startDate!.toLocal()} → ${endDate!.toLocal()}'
                          : 'Selected start: ${startDate!.toLocal()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (startDate != null && endDate != null)
                          ? () {
                              // Do something with the selected range
                              // Example: call repository to make a reservation
                              print('Booking confirmed: $startDate → $endDate');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Booking confirmed: ${startDate!.toLocal()} → ${endDate!.toLocal()}',
                                  ),
                                ),
                              );
                            }
                          : null, // disable if range is not selected
                      child: const Text('Confirm Booking'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
