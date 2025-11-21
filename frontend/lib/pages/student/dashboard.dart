import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:frontend/core/config/env.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late String _token;
  Map<String, dynamic>? _studentProfile;
  List<dynamic>? _courses;
  Map<String, dynamic>? _attendanceSummary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token') ?? '';

      if (_token.isEmpty) {
        setState(() {
          _error = 'No authentication token found. Please log in.';
          _isLoading = false;
        });
        return;
      }

      await Future.wait([
        _fetchStudentProfile(),
        _fetchCourses(),
        _fetchAttendanceSummary(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStudentProfile() async {
    final response = await http.get(
      Uri.parse('${Env.apiBaseUrl}/student/profile'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      _studentProfile = json.decode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> _fetchCourses() async {
    final response = await http.get(
      Uri.parse('${Env.apiBaseUrl}/student/courses'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      _courses = json.decode(response.body);
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<void> _fetchAttendanceSummary() async {
    final response = await http.get(
      Uri.parse('${Env.apiBaseUrl}/student/attendance/summary'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      _attendanceSummary = json.decode(response.body);
    } else {
      throw Exception('Failed to load attendance summary');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${_studentProfile?['name'] ?? 'Student'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${_studentProfile?['email'] ?? ''}'),
                    Text('Student ID: ${_studentProfile?['studentId'] ?? ''}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Attendance Summary Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Classes: ${_attendanceSummary?['totalClasses'] ?? 0}',
                    ),
                    Text('Attended: ${_attendanceSummary?['attended'] ?? 0}'),
                    Text(
                      'Percentage: ${_attendanceSummary?['percentage']?.toStringAsFixed(2) ?? '0.00'}%',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Enrolled Courses
            const Text(
              'Enrolled Courses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_courses != null && _courses!.isNotEmpty)
              ..._courses!.map(
                (course) => Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(course['name'] ?? 'Course Name'),
                    subtitle: Text('Code: ${course['code'] ?? ''}'),
                    trailing: Text(course['teacher'] ?? ''),
                  ),
                ),
              )
            else
              const Text('No courses enrolled.'),

            const SizedBox(height: 16),

            // Placeholder for QR Scan
            ElevatedButton(
              onPressed: () {
                // TODO: Implement QR scan functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR Scan feature coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Scan QR for Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
