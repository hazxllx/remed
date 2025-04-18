import 'package:flutter/material.dart';
import 'homepage.dart'; // Make sure HomePage is implemented and accepts a username

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _patientCodeController = TextEditingController();

  String? _selectedRole;
  bool get _requiresPatientCode => _selectedRole == 'Nurse' || _selectedRole == 'Family';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  void _register() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(username: _usernameController.text),
        ),
      );
    }
  }

  void _registerWithGoogle() {
    // TODO: Add Google sign-in logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-in not implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hello! Register to get started",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEB5E5E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: "Username",
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.isEmpty ? 'Enter username' : null,
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.isEmpty ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: const OutlineInputBorder(borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 12),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_confirmPasswordVisible,
                    decoration: InputDecoration(
                      hintText: "Confirm password",
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: const OutlineInputBorder(borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) =>
                        value != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 12),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'Patient', child: Text('Patient')),
                      DropdownMenuItem(value: 'Nurse', child: Text('Nurse')),
                      DropdownMenuItem(value: 'Family', child: Text('Family')),
                    ],
                    onChanged: (value) => setState(() => _selectedRole = value),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      hintText: "Select Role",
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    validator: (value) => value == null ? 'Select a role' : null,
                  ),
                  const SizedBox(height: 12),

                  // Patient Code (if role requires it)
                  if (_requiresPatientCode)
                    TextFormField(
                      controller: _patientCodeController,
                      decoration: const InputDecoration(
                        hintText: "Patient Code",
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      validator: (value) =>
                          _requiresPatientCode && value!.isEmpty ? 'Enter patient code' : null,
                    ),

                  const SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEB5E5E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _register,
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Or divider
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("Or", style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Google Sign-in Styled Button
                  GestureDetector(
                    onTap: _registerWithGoogle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFEB5E5E)),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/google_icon.png', // Make sure this exists
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Continue with Google",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // or navigate to LoginScreen
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xFFEB5E5E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
