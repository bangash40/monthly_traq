import 'package:flutter/material.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/auth/login_screen.dart';

class MonthlyTraqApp extends StatelessWidget {
  const MonthlyTraqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonthlyTraq',
      debugShowCheckedModeBanner: true,
      home: const LoginScreen(),
      theme: monthlyTraqTheme(),
    );
  }
}
