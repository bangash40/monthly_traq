import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/launch_intro.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/offline_banner.dart';
import 'package:monthly_traq/app/onboarding_gate.dart';
import 'package:monthly_traq/app/theme_controller.dart';
import 'package:monthly_traq/l10n/l10n.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/goals_repository.dart';
import 'package:monthly_traq/services/investments_repository.dart';
import 'package:monthly_traq/services/repayments_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/services/write_sync.dart';

/// The app-wide snackbar host, for notes that come from outside any screen.
final _messenger = GlobalKey<ScaffoldMessengerState>();

/// "Saved on your phone…" after a save or delete made without a
/// connection. It waits a moment so a screen's own message (a delete's
/// "Undo") shows first and stays in reach.
void _showSavedOfflineNote() {
  Future.delayed(const Duration(milliseconds: 700), () {
    final messenger = _messenger.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(messenger.context.l10n.savedOffline)),
    );
  });
}

class MonthlyTraqApp extends StatelessWidget {
  const MonthlyTraqApp({super.key});

  @override
  Widget build(BuildContext context) {
    onSavedOffline = _showSavedOfflineNote;
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
          final languageCode = context.select<AppSettings, String?>(
            (s) => s.languageCode,
          );
          return MaterialApp(
            title: 'MonthlyTraq',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Null follows the phone's language, falling back to English.
            locale: languageCode == null ? null : Locale(languageCode),
            scaffoldMessengerKey: _messenger,
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
                child: LaunchIntro(child: OfflineBannerFrame(child: child!)),
              );
            },
          );
        },
      ),
    );
  }
}
