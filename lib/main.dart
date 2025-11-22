import 'package:flutter/material.dart';
import 'package:library_app/Login.dart';
import 'package:library_app/MainPage.dart';
import 'package:library_app/AdminMain.dart';

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
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6D28D9), //بنفسجي انيق
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),

      //to navigate between pages
      initialRoute: '/AdminMain',
      routes: {
        '/Login': (context) => const Login(),
        '/MainPage': (context) => const HomePage(),
        '/AdminMain': (context) => const AdminHomePage(),
      }, // Placeholder for MainPage},
    );
  }
}
