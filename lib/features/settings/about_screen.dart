import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:monthly_traq/app/app_info.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// Profile → More → About: the app logo (in the current theme's color), its
/// name, and the full version with the build number, e.g. "Version 1.4.4 (9)".
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SubPageScaffold(
      title: 'About',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
        children: [
          const Center(child: AppLogoTile(size: 96)),
          const SizedBox(height: 24),
          const Text(
            AppInfo.name,
            textAlign: TextAlign.center,
            style: AppText.titleLarge,
          ),
          const SizedBox(height: 8),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              return Text(
                info == null
                    ? ''
                    : 'Version ${info.version} (${info.buildNumber})',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  fontSize: 16,
                  color: c.muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Track your income, expenses and monthly budget.',
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(fontSize: 16, color: c.muted),
          ),
        ],
      ),
    );
  }
}
