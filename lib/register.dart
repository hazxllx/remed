import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'onboarding.dart';
import 'add_medicine.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _patientCodeController = TextEditingController();

  String? selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> roles = ['Patient', 'Nurse', 'Family'];

  Medicine? _selectedMedicine;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _patientCodeController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = selectedRole!;
    final patientCode = _patientCodeController.text.trim();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'role': role,
        if (role != 'Patient') 'patientCode': patientCode,
        'createdAt': FieldValue.serverTimestamp(),
        if (_selectedMedicine != null)
          'medicine': {
            'name': _selectedMedicine!.name,
            'type': _selectedMedicine!.type,
            'dose': _selectedMedicine!.dose,
            'amount': _selectedMedicine!.amount,
            'reminderTimes': _selectedMedicine!.reminderTimes
                .map((t) => '${t.hour}:${t.minute}')
                .toList(),
          },
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen(username: username)),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed.";
      if (e.code == 'email-already-in-use') {
        message = 'Email is already in use.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': user.displayName ?? '',
          'email': user.email,
          'role': 'Patient',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen(username: user.displayName ?? '')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign-In failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                const Text(
                  "Hello! Register to get started",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _usernameController,
                  hintText: "Username",
                  validator: (value) => value == null || value.trim().isEmpty ? 'Username is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  hintText: "Email",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email is required';
                    if (!isValidEmail(value.trim())) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  obscureText: _obscurePassword,
                  toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: _obscureConfirmPassword,
                  toggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    hintText: 'Select Role',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  items: roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                  onChanged: (value) => setState(() => selectedRole = value),
                  validator: (value) => value == null ? 'Role is required' : null,
                ),
                if (selectedRole == 'Nurse' || selectedRole == 'Family') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _patientCodeController,
                    hintText: "Patient Code",
                    validator: (value) => value == null || value.trim().isEmpty ? 'Patient code is required' : null,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Register", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Or"),
                  ),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Image.asset('assets/google_icon.png', height: 24),
                    label: const Text("Continue with Google", style: TextStyle(color: Colors.black)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.alarm_add),
                    label: const Text("Add Reminder"),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddMedicinePage()),
                      );

                      if (result != null && result is Medicine) {
                        setState(() {
                          _selectedMedicine = result;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                if (_selectedMedicine != null) ...[
                  const SizedBox(height: 16),
                  const Text("Selected Reminder:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Name: ${_selectedMedicine!.name}"),
                  Text("Dose: ${_selectedMedicine!.dose}"),
                  Text("Amount: ${_selectedMedicine!.amount}"),
                  if (_selectedMedicine!.reminderTimes.isNotEmpty) ...[
                    const Text("Times:"),
                    ..._selectedMedicine!.reminderTimes.map((t) => Text("• ${t.format(context)}")),
                  ]
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              )
            : null,
      ),
    );
  }
}
