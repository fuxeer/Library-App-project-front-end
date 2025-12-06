import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_app/Login.dart';
import 'package:library_app/Pages/MainPage.dart';
import 'package:library_app/AdminMain.dart';
import 'package:library_app/Login_test.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
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
      initialRoute: '/Login',
      routes: {
        '/Login': (context) => const Login(),
        '/MainPage': (context) => const HomePage(),
        '/AdminMain': (context) => const AdminHomePage(),
      }, // Placeholder for MainPage},
    );
  }
}
