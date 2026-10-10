import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/launch_intro.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/onboarding_gate.dart';
import 'package:monthly_traq/app/theme_controller.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/goals_repository.dart';
import 'package:monthly_traq/services/investments_repository.dart';
import 'package:monthly_traq/services/repayments_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';

class MonthlyTraqApp extends StatelessWidget {
  const MonthlyTraqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionsRepository()),
        ChangeNotifierProvider(create: (context) => WalletsRepository()),
        ChangeNotifierProvider(create: (context) => RepaymentsRepository()),
        ChangeNotifierProvider(create: (context) => GoalsRepository()),
        ChangeNotifierProvider(create: (context) => InvestmentsRepository()),
        ChangeNotifierProvider(create: (context) => ThemeController()),
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ProxyProvider2<TransactionsRepository, AppSettings, MoneyFormatter>(
          update: (context, repo, settings, previous) => MoneyFormatter(
            symbol: repo.currencySymbol,
            grouping: settings.thousandsSeparator,
          ),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          final theme = themeController.theme;
          return MaterialApp(
            title: 'MonthlyTraq',
            debugShowCheckedModeBanner: false,
            home: const OnboardingGate(),
            theme: theme.themeData(Brightness.light),
            darkTheme: theme.themeData(Brightness.dark),
            themeMode: themeController.mode,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(
                    mediaQuery.textScaler.scale(1) * themeController.fontScale,
                  ),
                ),
                child: LaunchIntro(child: child!),
              );
            },
          );
        },
      ),
    );
  }
}
