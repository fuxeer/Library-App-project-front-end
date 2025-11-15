import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'model/User.dart';
import 'model/CurrentUser.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  bool _loading = false;
  String? _errormessage;

  @override
  Widget build(BuildContext context) {
    //function to handle login
    Future<void> login() async {
      final username = _usernamecontroller.text.trim();
      final password = _passwordcontroller.text.trim();

      if (username.isEmpty || password.isEmpty) {
        setState(() {
          _errormessage = "Please enter both username and password";
        });
        return;
      }

      setState(() {
        _loading = true;
        _errormessage = null;
      });

      final url = Uri.parse("https://localhost:7145/api/Users/login");

      //HTTP POST request
      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"userName": username, "password": password}),
        );

        if (!mounted) return;
        // successful login
        if (response.statusCode == 200) {
          // parse user data
          final responseData = jsonDecode(response.body);
          currentUser = User.fromJson(responseData);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/MainPage', // go to MainPage
            (route) => false, // remove all previous pages
          );
        }
        // invalid user input
        else if (response.statusCode == 401) {
          setState(() {
            _errormessage = "Invalid username or password";
          });
        } else {
          setState(() {
            _errormessage = response.statusCode.toString();
          });
        }
      }
      //
      catch (e) {
        if (!mounted) return;
        setState(() {
          _errormessage = "Error: Connecton failed";
          print(e);
        });
      }
      //
      finally {
        if (!mounted) return;
        setState(() {
          _loading = false;
        });
      }
    }

    //the full page
    return Scaffold(
      body: Stack(
        children: [
          //background gradient color
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.0,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).primaryColorLight,
                  Colors.white70,
                ],
                stops: [0.0, 0.7, 1.0],
              ),
            ),
          ),

          //Logo
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Icon(
              Icons.menu_book_sharp,
              size: 59,
              color: Colors.white.withAlpha(150),
            ),
          ),

          //title text
          Positioned(
            top: 159,
            left: 0,
            right: 0,
            child: Text(
              "Welcom",
              style: TextStyle(
                fontSize: 70,
                color: Colors.black.withAlpha(200),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          //Middle Container
          Center(
            child: Container(
              width: 350,

              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withGreen(50),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(10),
                    blurStyle: BlurStyle.inner,
                    blurRadius: 20,
                  ),
                ],
              ),

              //content inside the container
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  //username input
                  Row(
                    children: [
                      SizedBox(width: 80, child: Text("UserName")),
                      Expanded(
                        child: TextField(
                          controller: _usernamecontroller,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  //password input
                  Row(
                    children: [
                      SizedBox(width: 80, child: Text("Password")),
                      Expanded(
                        child: TextField(
                          controller: _passwordcontroller,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  //buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //login button
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: login,
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.green,
                                )
                              : Text("Login"),
                        ),
                      ),

                      //register button
                      /*SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () => debugPrint("Register"),
                          child: Text("Register"),
                        ),
                      )*/
                    ],
                  ),
                  // Show error message if exists
                  if (_errormessage != null) ...[
                    SizedBox(height: 10),
                    Text(
                      _errormessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
