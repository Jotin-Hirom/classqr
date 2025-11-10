import 'package:flutter/material.dart';
import 'package:frontend/api/api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const BackendTestWidget(),
    );
  }
}




// class BackendTestWidget extends StatefulWidget {
//   const BackendTestWidget({super.key});

//   @override
//   State<BackendTestWidget> createState() => _BackendTestWidgetState();
// }

// class _BackendTestWidgetState extends State<BackendTestWidget> {
//   final ApiService _api = ApiService();
//   String _message = 'Connecting...';

//   @override
//   void initState() {
//     super.initState();
//     _connect();
//   }

//   void _connect() async {
//     try {
//       final msg = await _api.testConnection();
//       setState(() => _message = msg);
//     } catch (e) {
//       setState(() => _message = 'Error: ${e.toString()}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       _message,
//       style: const TextStyle(fontSize: 18),
//     );
//   }
// }