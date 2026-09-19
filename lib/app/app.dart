import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/onboarding_gate.dart';
import 'package:monthly_traq/app/theme_controller.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

class MonthlyTraqApp extends StatelessWidget {
  const MonthlyTraqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionsRepository()),
        ChangeNotifierProvider(create: (context) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'MonthlyTraq',
            debugShowCheckedModeBanner: false,
            home: const OnboardingGate(),
            theme: themeController.lightPreset.toThemeData(),
            darkTheme: themeController.darkPreset.toThemeData(),
            themeMode: themeController.mode,
          );
        },
      ),
    );
  }
}
