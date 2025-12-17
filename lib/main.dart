import 'package:flutter/material.dart';
import 'package:multi_agences_app/screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Agences Pro',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      //  home: SignupScreen(),
      home: LoginScreen(),
    );
  }
}
