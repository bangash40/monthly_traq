import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/l10n/l10n.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// Each language's name in that language, so people can find their own.
const _nativeNames = {'en': 'English', 'ur': 'اردو'};

/// The name to show for the chosen language: its own name, or "System
/// default" when following the phone.
String languageLabel(BuildContext context, String? code) =>
    code == null ? context.l10n.languageSystem : _nativeNames[code] ?? code;

/// Lets the person pick the app's language, or follow the phone's.
Future<void> showLanguagePicker(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => const _LanguagePicker(),
);

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final current = context.select<AppSettings, String?>((s) => s.languageCode);
    final codes = <String?>[
      null,
      for (final locale in AppLocalizations.supportedLocales)
        locale.languageCode,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.languageTitle,
            style: AppText.section.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          GroupCard(
            children: [
              for (final code in codes)
                InkWell(
                  onTap: () {
                    context.read<AppSettings>().setLanguageCode(code);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            languageLabel(context, code),
                            style: AppText.rowTitle.copyWith(fontSize: 16),
                          ),
                        ),
                        Icon(
                          code == current
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: code == current ? c.accent : c.faint,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
