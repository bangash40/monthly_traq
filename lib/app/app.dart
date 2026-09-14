import 'package:flutter/material.dart';
import 'package:monthly_traq/app/auth_gate.dart';
import 'package:monthly_traq/app/theme.dart';

class MonthlyTraqApp extends StatelessWidget {
  const MonthlyTraqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonthlyTraq',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: monthlyTraqTheme(),
    );
  }
}
