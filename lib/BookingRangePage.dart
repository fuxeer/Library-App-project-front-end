import 'package:flutter/material.dart';
import '../model/Book.dart';

class BookingRangePage extends StatefulWidget {
  final Book book;

  const BookingRangePage({super.key, required this.book});

  @override
  State<BookingRangePage> createState() => _BookingRangePageState();
}

class _BookingRangePageState extends State<BookingRangePage> {
  DateTime? start;
  DateTime? end;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book: ${widget.book.Title}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                );

                if (range != null) {
                  setState(() {
                    start = range.start;
                    end = range.end;
                  });
                }
              },
              child: const Text("Select Duration"),
            ),

            const SizedBox(height: 20),

            if (start != null)
              Text(
                "Start: ${start!.toString().split(' ')[0]}",
                style: const TextStyle(fontSize: 16),
              ),

            if (end != null)
              Text(
                "End: ${end!.toString().split(' ')[0]}",
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 30),

            if (start != null && end != null)
              ElevatedButton(
                onPressed: () {
                  // TODO: send reservation to backend
                },
                child: const Text("Confirm Booking"),
              ),
          ],
        ),
      ),
    );
  }
}
