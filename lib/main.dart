import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'splash_welcome.dart';
import 'login.dart' as login;
import 'register.dart' as register;
import 'homepage.dart';
import 'onboarding.dart';
import 'add_medicine.dart'; // ✅ Ensure this is included

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingShown = prefs.getBool('onboardingShown') ?? false;

  runApp(MyApp(onboardingShown: onboardingShown));
}

class MyApp extends StatelessWidget {
  final bool onboardingShown;

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
      initialRoute: onboardingShown ? '/splash' : '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/splash': (context) => const SplashScreen(),
        '/login': (_) => const login.LoginScreen(),
        '/register': (_) => const register.RegisterScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final username = args?['username'] ?? 'User';
          return HomePage(username: username);
        },
        '/addMedicine': (_) => const AddMedicinePage(), 
      },
    );
  }
}
