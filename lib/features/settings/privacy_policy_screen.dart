import 'package:flutter/material.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/settings/privacy_policy.dart';
import 'package:monthly_traq/widgets/ui.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final body = AppText.body.copyWith(
      fontSize: 16,
      height: 1.5,
      color: c.muted,
    );

    return SubPageScaffold(
      title: 'Privacy policy',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          for (final section in privacyPolicy) ...[
            const SizedBox(height: 20),
            Text(
              section.heading,
              style: AppText.section.copyWith(fontSize: 19),
            ),
            for (final paragraph in section.paragraphs) ...[
              const SizedBox(height: 8),
              Text(paragraph, style: body),
            ],
            for (final bullet in section.bullets)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 9, right: 12),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: c.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(child: Text(bullet, style: body)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
