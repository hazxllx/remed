import 'package:flutter/material.dart';
import 'splash_welcome.dart'; // <-- Fix import: make sure this file exists at project root or use correct path
import 'login.dart' as login;
import 'register.dart' as register;
import 'homepage.dart'; // <-- Keep as is, assuming it’s correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REMED',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      // SplashScreen should be correctly imported
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const login.LoginScreen(),
        '/register': (_) => const register.RegisterScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return HomePage(username: args['username']);
        },
      },
    );
  }
}
