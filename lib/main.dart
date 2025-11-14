import 'package:flutter/material.dart';
import 'package:library_app/Login.dart';
import 'package:library_app/MainPage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //color theme for the app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),

      //to navigate between pages
      initialRoute: '/Homepage',
      routes: {
        '/Login': (context) => const Login(),
        '/Homepage': (context) => const HomePage(),
      }, // Placeholder for MainPage},
    );
  }
}
