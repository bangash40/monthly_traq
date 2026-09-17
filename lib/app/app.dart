import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/onboarding_gate.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

class MonthlyTraqApp extends StatelessWidget {
  const MonthlyTraqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionsRepository(),
      child: MaterialApp(
        title: 'MonthlyTraq',
        debugShowCheckedModeBanner: false,
        home: const OnboardingGate(),
        theme: monthlyTraqTheme(),
      ),
    );
  }
}
