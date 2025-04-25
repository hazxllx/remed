import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'splash_welcome.dart'; // Contains SplashScreen
import 'login.dart' as login;
import 'register.dart' as register;
import 'homepage.dart';
import 'onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp()); // No parameters needed
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ Clean constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REMED',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Always start from SplashScreen
      routes: {
        '/login': (_) => const login.LoginScreen(),
        '/register': (_) => const register.RegisterScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final username = args?['username'] ?? 'User';
          return HomePage(username: username);
        },
      },
    );
  }
}
