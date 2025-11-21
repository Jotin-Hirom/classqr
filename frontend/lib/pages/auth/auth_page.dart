import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/components/forgot_password.dart';
import 'package:frontend/pages/auth/components/login.dart';
import 'package:frontend/pages/auth/components/signup.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int _selectedIndex = 0;

  final List<Widget> screens = const [
    LoginPage(),
    SignupPage(),
    ForgotPasswordPage(),
  ];

  final List<String> titles = ["Sign In", "Sign Up", "Forgot"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2FA),

      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.indigo,
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  // ------------------ TOP BAR TITLE ------------------
                  const Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text(
                      "ClassQR",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ------------------ TABS ------------------
            Container(
              height: 50,
              width: 370,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: List.generate(3, (index) {
                  bool active = _selectedIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          titles[index],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: active
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: active ? Colors.black : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------ ACTIVE SCREEN ------------------
            Expanded(child: screens[_selectedIndex]),
          ],
        ),
      ),
    );
  }
}
