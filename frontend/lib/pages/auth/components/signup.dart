import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/core/config/env.dart';
import 'package:frontend/pages/auth/components/login.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  void initState() {
    super.initState();
    loadDepartments();
  }

  // Form Keys
  GlobalKey<FormState> studentKey = GlobalKey<FormState>();
  GlobalKey<FormState> teacherKey = GlobalKey<FormState>();

  // Role selection
  String selectedRole = "Student";

  // Designation selection for teachers
  String selectedDesignation = "Assistant Professor";

  // Department selection for teachers
  String? selectedDepartment;
  List<String> departments = [];

  Future<void> loadDepartments() async {
    try {
      final csvData = await rootBundle.loadString(
        'assets/departments/tezpur_departments.csv',
      );

      final lines = csvData.split('\n');

      final list = lines
          .skip(1)
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      setState(() {
        departments = list;
        selectedDepartment = list.isNotEmpty ? list.first : null;
      });

      print("Departments Loaded: $departments");
    } catch (e) {
      print("Error loading CSV: $e");
    }
  }

  // ---------------- STUDENT CONTROLLERS ----------------
  final name = TextEditingController();
  final roll = TextEditingController();
  final semester = TextEditingController();
  final programme = TextEditingController();
  final batch = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // ---------------- TEACHER CONTROLLERS ----------------
  final tName = TextEditingController();
  final tSpecialization = TextEditingController();
  final tEmail = TextEditingController();
  final tPassword = TextEditingController();
  final tConfirmPassword = TextEditingController();

  // ------------------------------------------------------
  // VALIDATION FUNCTIONS
  // ------------------------------------------------------

  String message = '';

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return "Name is required";
    if (!RegExp(r'^[A-Za-z ]+$').hasMatch(v)) return "Only alphabets allowed";
    return null;
  }

  String? validateRoll(String? v) {
    if (v == null || v.isEmpty) return "Roll number is required";
    if (!RegExp(r'^[A-Za-z]{3}[0-9]{5}$').hasMatch(v)) {
      return "Format: ABC12345";
    }
    return null;
  }

  String? validateSemester(String? v) {
    if (v == null || v.trim().isEmpty) return "Semester is required";
    final s = int.tryParse(v.trim());
    if (s == null || s < 1 || s > 10) return "Semester must be between 1–10";
    return null;
  }

  String? validateProgramme(String? v) {
    if (v == null || v.isEmpty) return "Programme is required";
    if (!RegExp(r'^[A-Za-z ]+$').hasMatch(v)) return "Only alphabets allowed";
    return null;
  }

  String? validateBatch(String? v) {
    if (v == null || v.trim().isEmpty) return "Batch Year is required";
    final val = v.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(val))
      return "Enter valid year (e.g. 2023)";
    return null;
  }

  String? validateStudentEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required";

    if (!v.endsWith("@tezu.ac.in")) {
      return "Student email must end with @tezu.ac.in";
    }

    if (roll.text.isEmpty) return "Enter Roll Number first";

    final prefix = v.split("@")[0];

    if (prefix.toLowerCase() != roll.text.toLowerCase()) {
      return "Email prefix must match Roll Number";
    }

    if (!RegExp(r'^[A-Za-z]{3}[0-9]{5}$').hasMatch(prefix)) {
      return "Roll must be ABC12345";
    }

    return null;
  }

  String? validateTeacherEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required";

    if (!v.endsWith("@tezu.ernet.in")) {
      return "Teacher email must end with @tezu.ernet.in";
    }

    final username = v.split("@")[0];

    if (!RegExp(r'^[A-Za-z][A-Za-z0-9._%+-]*$').hasMatch(username)) {
      return "Email must start with a letter and contain letters/numbers";
    }

    return null;
  }

  String? validateTeacherName(String? v) {
    if (v == null || v.isEmpty) return "Name is required";
    return null;
  }

  String? validateDesignation(String? v) {
    if (v == null || v.trim().isEmpty) return "Designation is required";
    return null;
  }

  String? validateSpecialization(String? v) {
    if (v == null || v.isEmpty) return "Specialization is required";
    return null;
  }

  String? validateDepartment(String? val) {
    if (val == null || val.isEmpty) return 'Please select a department';
    // Normalize
    final cleaned = val.trim();
    if (!departments.contains(cleaned)) return 'Invalid department';
    return null;
  }

  String? validatePasswordField(String? v) {
    if (v == null || v.isEmpty) return "Password is required";
    final regex = RegExp(
      r'^(?=(.*[A-Za-z]){4,})(?=.*\d)(?=.*[^A-Za-z0-9]).{6,}$',
    );
    if (!regex.hasMatch(v)) {
      return "Min 6 chars, 4 letters, 1 digit, 1 symbol";
    }
    return null;
  }

  String? validateConfirmPassword(String? v, TextEditingController ctrl) {
    if (v != ctrl.text) return "Passwords do not match";
    return null;
  }

  // ------------------------------------------------------
  // LOAD DEPARTMENTS
  // ------------------------------------------------------

  // ------------------------------------------------------
  // RESET ON ROLE SWITCH
  // ------------------------------------------------------

  void onRoleChange(String role) {
    setState(() {
      selectedRole = role;
      studentKey = GlobalKey<FormState>();
      teacherKey = GlobalKey<FormState>();
    });
  }

  // ------------------------------------------------------
  // SUBMIT
  // ------------------------------------------------------

  void submit() async {
    if (selectedRole == "Student") {
      if (studentKey.currentState!.validate()) {
        try {
          final res = await http.post(
            Uri.parse('${Env.apiBaseUrl}/api/auth/signup'),
            body: {
              'email': email.text.toLowerCase(),
              'password': password.text.trim(),
              'sname': name.text.trim(),
              'role': selectedRole.toLowerCase(),
              'roll_no': roll.text.trim(),
              'semester': semester.text.trim(),
              'programme': programme.text.toUpperCase(),
              'batch': batch.text.trim(),
            },
          );
          if (res.statusCode == 200 || res.statusCode == 201) {
            // Clear all controllers
            name.clear();
            roll.clear();
            semester.clear();
            programme.clear();
            batch.clear();
            email.clear();
            password.clear();
            confirmPassword.clear();
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
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            try {
              final Map<String, dynamic> body = jsonDecode(res.body);
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
      }
    } else {
      if (teacherKey.currentState!.validate()) {
        try {
          final res = await http.post(
            Uri.parse('${Env.apiBaseUrl}/api/auth/signup'),
            body: {
              'tname': tName.text.trim(),
              'designation': selectedDesignation,
              'specialization': tSpecialization.text.trim(),
              'dept': selectedDepartment,
              'email': tEmail.text.toLowerCase(),
              'password': tPassword.text.trim(),
              'role': selectedRole.toLowerCase(),
            },
          );
          if (res.statusCode == 200 || res.statusCode == 201) {
            // Clear all controllers
            tName.clear();
            tSpecialization.clear();
            tEmail.clear();
            tPassword.clear();
            tConfirmPassword.clear();
            toastification.show(
              type: ToastificationType.success,
              style: ToastificationStyle.flat,
              alignment: Alignment.topCenter,
              context: context,
              title: Text('Teacher Account created successfully.'),
              autoCloseDuration: const Duration(seconds: 5),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            try {
              final Map<String, dynamic> body = jsonDecode(res.body);
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
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    roll.dispose();
    semester.dispose();
    programme.dispose();
    batch.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    tName.dispose();
    tSpecialization.dispose();

    tEmail.dispose();
    tPassword.dispose();
    tConfirmPassword.dispose();
    super.dispose();
  }

  // ------------------------------------------------------
  // UI (CLEANED)
  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // ---------- ROLE DROPDOWN ----------
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: fieldStyle("Select Role"),
                borderRadius: BorderRadius.circular(12),
                items: const [
                  DropdownMenuItem(value: "Student", child: Text("Student")),
                  DropdownMenuItem(value: "Teacher", child: Text("Teacher")),
                ],
                onChanged: (v) => onRoleChange(v!),
              ),

              const SizedBox(height: 20),

              // ---------- FORM ----------
              selectedRole == "Student" ? studentForm() : teacherForm(),

              const SizedBox(height: 20),

              // ---------- SUBMIT BUTTON ----------
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: submit,
                  child: Text(
                    "Create $selectedRole Account",
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

  // ------------------------------------------------------
  // STUDENT FORM UI
  // ------------------------------------------------------

  Widget studentForm() {
    return Form(
      key: studentKey,
      child: Column(
        children: [
          field(name, "Full Name", validateName),
          const SizedBox(height: 12),
          field(roll, "Roll Number", validateRoll),
          const SizedBox(height: 12),
          field(
            semester,
            "Semester",
            validateSemester,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 12),
          field(programme, "Programme", validateProgramme),
          const SizedBox(height: 12),
          field(
            batch,
            "Batch Year",
            validateBatch,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 12),
          field(email, "Email", validateStudentEmail),
          const SizedBox(height: 12),
          field(password, "Password", validatePasswordField, obscure: true),
          const SizedBox(height: 12),
          field(
            confirmPassword,
            "Confirm Password",
            (v) => validateConfirmPassword(v, password),
            obscure: true,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // TEACHER FORM UI
  // ------------------------------------------------------

  Widget teacherForm() {
    return Form(
      key: teacherKey,
      child: Column(
        children: [
          field(tName, "Full Name", validateTeacherName),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: selectedDesignation,
            decoration: fieldStyle("Select Designation"),
            borderRadius: BorderRadius.circular(12),
            items: const [
              DropdownMenuItem(
                value: "Assistant Professor",
                child: Text("Assistant Professor"),
              ),
              DropdownMenuItem(
                value: "Associate Professor",
                child: Text("Associate Professor"),
              ),
              DropdownMenuItem(value: "Professor", child: Text("Professor")),
              DropdownMenuItem(value: "Lecturer", child: Text("Lecturer")),
              DropdownMenuItem(
                value: "Senior Lecturer",
                child: Text("Senior Lecturer"),
              ),
              DropdownMenuItem(
                value: "Visiting Faculty",
                child: Text("Visiting Faculty"),
              ),
            ],
            onChanged: (v) => setState(() => selectedDesignation = v!),
            validator: validateDesignation,
          ),
          const SizedBox(height: 12),
          field(tSpecialization, "Specialization", validateSpecialization),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedDepartment,
            decoration: fieldStyle("Select Department"),
            borderRadius: BorderRadius.circular(12),
            items: departments
                .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
                .toList(),
            onChanged: (v) {
              setState(() => selectedDepartment = v?.trim());
            },
            validator: validateDepartment,
          ),
          const SizedBox(height: 12),
          field(tEmail, "Email", validateTeacherEmail),
          const SizedBox(height: 12),
          field(tPassword, "Password", validatePasswordField, obscure: true),
          const SizedBox(height: 12),
          field(
            tConfirmPassword,
            "Confirm Password",
            (v) => validateConfirmPassword(v, tPassword),
            obscure: true,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // INPUT FIELD REUSABLE
  // ------------------------------------------------------

  Widget field(
    TextEditingController controller,
    String label,
    String? Function(String?) validator, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: validator,
      decoration: fieldStyle(label),
    );
  }

  InputDecoration fieldStyle(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
