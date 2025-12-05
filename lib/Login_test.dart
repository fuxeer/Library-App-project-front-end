import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_app/providers/CurrentUser_provider.dart';

class LoginTest extends ConsumerStatefulWidget {
  const LoginTest({super.key});

  @override
  ConsumerState<LoginTest> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginTest> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    Future<void> login() async {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = "Please enter both username and password";
        });
        return;
      }

      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      try {
        final success = await ref
            .read(currentUserProvider.notifier)
            .login(username, password);

        if (!mounted) return;

        if (success) {
          // Navigate to MainPage
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/MainPage',
            (route) => false,
          );
        } else {
          setState(() {
            _errorMessage = "Invalid username or password";
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = "Error: Connection failed";
        });
      } finally {
        if (!mounted) return;
        setState(() {
          _loading = false;
        });
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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

          // Logo
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

          // Title
          Positioned(
            top: 159,
            left: 0,
            right: 0,
            child: Text(
              "Welcome",
              style: TextStyle(
                fontSize: 70,
                color: Colors.black.withAlpha(200),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Login Form
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Username
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : login,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Login"),
                    ),
                  ),

                  // Error Message
                  if (_errorMessage != null) ...[
                    SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
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
