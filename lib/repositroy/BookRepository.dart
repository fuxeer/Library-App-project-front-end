import "dart:convert";
import "package:http/http.dart" as http;
import "package:library_app/model/Book.dart";
import 'package:library_app/model/BookingRange.dart';

class BookRepository {
  Future<List<Book>> getAllBooks() async {
    final url = Uri.parse("https://localhost:7145/api/Books");

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final books = jsonData.map((item) => Book.fromJson(item)).toList();
        return books;
      }
    } catch (e) {
      print(e);
    }
    // Return an empty list in case of error
    return [];
  }

  Future<List<BookingRange>> getBookedRanges(int bookId) async {
    final url = Uri.parse(
      "https://localhost:7145/api/Reservation/available/$bookId",
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => BookingRange.fromJson(e)).toList();
      }
    } catch (e) {
      print(e);
    }
    return [];
  }
}
