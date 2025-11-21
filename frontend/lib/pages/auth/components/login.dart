import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/core/config/env.dart';
import 'package:frontend/pages/auth/components/home.dart';
import 'package:frontend/pages/student/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  String message = '';
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Email"),
              const SizedBox(height: 8),
              // Image(image: AssetImage('assets/google.png'), height: 50),
              TextField(
                controller: email,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  hintText: "@tezu.ac.in or @tezu.ernet.in",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text("Password"),
              const SizedBox(height: 8),

              TextField(
                obscureText: true,
                controller: password,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: "Enter your password",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final res = await http.post(
                        Uri.parse('${Env.apiBaseUrl}/api/auth/login'),
                        body: {
                          'email': email.text.toLowerCase(),
                          'password': password.text.trim(),
                        },
                      );
                      if (res.statusCode == 200 || res.statusCode == 201) {
                        // Clear all controllers
                        email.clear();
                        password.clear();

                        toastification.show(
                          type: ToastificationType.success,
                          style: ToastificationStyle.flat,
                          alignment: Alignment.topCenter,
                          context: context,
                          title: Text("Student Account created successfully."),
                          autoCloseDuration: const Duration(seconds: 5),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentDashboard(),
                          ),
                        );
                      } else {
                        try {
                          final Map<String, dynamic> body = jsonDecode(
                            res.body,
                          );
                          message = body['message']?.toString() ?? res.body;
                        } catch (_) {
                          message = res.body;
                        }
                        toastification.show(
                          type: ToastificationType.error,
                          style: ToastificationStyle.flat,
                          alignment: Alignment.topCenter,
                          context: context,
                          title: Text(message),
                          autoCloseDuration: const Duration(seconds: 5),
                        );
                      }
                    } catch (e) {
                      toastification.show(
                        type: ToastificationType.error,
                        style: ToastificationStyle.flat,
                        alignment: Alignment.topCenter,
                        context: context,
                        title: Text(e.toString()),
                        autoCloseDuration: const Duration(seconds: 5),
                      );
                    }
                  },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
