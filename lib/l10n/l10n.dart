import 'package:flutter/widgets.dart';
import 'package:monthly_traq/l10n/app_localizations.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/services/cycle_stats.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

export 'package:monthly_traq/l10n/app_localizations.dart';

/// The app's text in the current language: `context.l10n.saveButton`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// An error for a "Could not …: {error}" message: the translated "no
/// internet" text when the server couldn't be reached, otherwise the
/// error's own text.
String errorMessage(AppLocalizations l10n, Object error) =>
    error is SyncTimeoutException ? l10n.noInternetTryAgain : '$error';

/// A category's name as shown, with the stand-in for deleted categories in
/// the current language.
extension CategoryDisplayName on CategoryModel {
  String displayName(AppLocalizations l10n) =>
      id == kUncategorizedId ? l10n.uncategorized : name;
}
