import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // <- add this

class ReservationRepository {
  Future<bool> reserveDate(
    int bookID,
    int userID,
    startDate,
    DateTime endDate,
  ) async {
    final url = Uri.parse("https://localhost:7145/api/Reservation/add");

    try {
      final formatter = DateFormat('yyyy-MM-dd');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UserId": userID,
          "Bookid": bookID,
          "StartDate": formatter.format(startDate),
          "DueDate": formatter.format(endDate),
        }),
      );
      print(response);
      print(response.body);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error reserving date: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserHistory(int userId) async {
    final url = Uri.parse(
      "https://localhost:7145/api/Reservation/$userId/history",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load user reservation history");
    }
  }
}
