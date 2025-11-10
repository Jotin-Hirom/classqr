import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

class ApiService {
  Future<String> testConnection() async {
    final response = await http.get(Uri.parse('$baseUrl/test'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'];
    } else {
      throw Exception('Failed to connect to backend');
    }
  }
}
