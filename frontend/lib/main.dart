import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/env.dart';
import 'app.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Load environment variables (optional)
  await Env.load(); // For API base URL, versioning, secrets if any
  
    // Enable Material 3 edge-to-edge UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: App()));
}