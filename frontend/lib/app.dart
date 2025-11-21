import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/auth_page.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  routes: [
    // ignore: unnecessary_underscores
    GoRoute(path: '/', redirect: (_, __) => '/signin'),
    GoRoute(path: '/signin', builder: (ctx, state) => const AuthPage()),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      title: 'CLass QR',
      theme: ThemeData(useMaterial3: true),
    );
  }
}
