import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this is generated via flutterfire configure
import 'package:shared_preferences/shared_preferences.dart'; // <-- Add this import

import 'splash_welcome.dart'; // Make sure this file exists
import 'login.dart' as login;
import 'register.dart' as register;
import 'homepage.dart'; // Ensure HomePage accepts a username parameter
import 'onboarding.dart'; // Import OnboardingScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ Proper Firebase init
  );
  
  // Fetch the onboarding status from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingShown = prefs.getBool('onboardingShown') ?? false;

  // Pass the onboarding status to MyApp
  runApp(MyApp(onboardingShown: onboardingShown));
}

class MyApp extends StatelessWidget {
  final bool onboardingShown;

  // Constructor expects the 'onboardingShown' parameter
  const MyApp({super.key, required this.onboardingShown});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REMED',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: onboardingShown ? const SplashScreen() : const OnboardingScreen(),
      routes: {
        '/login': (_) => const login.LoginScreen(),
        '/register': (_) => const register.RegisterScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final username = args?['username'] ?? 'User';
          return HomePage(username: username);
        },
      },
    );
  }
}
