import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:library_app/model/User.dart';

class UserRepository {
  Future<User?> GetUser(String username, String password) async {
    final url = Uri.parse("https://localhost:7145/api/Users/login");

    //HTTP POST request
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userName": username, "password": password}),
      );

      if (response.statusCode == 200) {
        // parse user data
        final responseData = jsonDecode(response.body);
        print(response.body);
        return User.fromJson(responseData);
      }
      // invalid user input
      else if (response.statusCode == 401) {
        //
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
