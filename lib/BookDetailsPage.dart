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
  final repository = BookRepository();
  List<BookingRange> availableRanges = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchAvailableRanges();
  }

  Future<void> fetchAvailableRanges() async {
    final ranges = await repository.getBookedRanges(widget.book.BookID);
    setState(() {
      availableRanges = ranges;
    });
  }

  bool isDateSelectable(DateTime date) {
    for (var range in availableRanges) {
      if (!date.isBefore(range.start) && !date.isAfter(range.end)) {
        return true;
      }
    }
    return false;
  }

  String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.Title)),
      body: availableRanges.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Info
                  Text(
                    widget.book.Title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Author: ${widget.book.Author}"),
                  Text("Category: ${widget.book.Category}"),
                  Text("Published: ${widget.book.PublishYear}"),
                  Text("Rating: ${widget.book.Rating} / 5"),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.book.Description ?? "",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Calendar
                  TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: startDate ?? DateTime.now(),
                    selectedDayPredicate: (day) =>
                        (startDate != null &&
                            day.isAtSameMomentAs(startDate!)) ||
                        (endDate != null && day.isAtSameMomentAs(endDate!)),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isDateSelectable(selectedDay)) return;

                      setState(() {
                        if (startDate == null ||
                            (startDate != null && endDate != null)) {
                          startDate = selectedDay;
                          endDate = null;
                        } else if (selectedDay.isBefore(startDate!)) {
                          startDate = selectedDay;
                        } else {
                          endDate = selectedDay;
                        }
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, _) {
                        final selectable = isDateSelectable(day);
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: selectable
                                ? Colors.green.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text("${day.day}"),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selected Range Display
                  Text(
                    startDate != null && endDate != null
                        ? "Selected: ${formatDate(startDate!)} → ${formatDate(endDate!)}"
                        : startDate != null
                        ? "Selected start: ${formatDate(startDate!)}"
                        : "No range selected",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: startDate != null && endDate != null
                          ? () {
                              // Call your booking API here
                              print(
                                "Booking from ${formatDate(startDate!)} to ${formatDate(endDate!)}",
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Booking confirmed!"),
                                ),
                              );
                            }
                          : null,
                      child: const Text("Confirm Booking"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
