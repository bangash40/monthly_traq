// Generates store/privacy-policy.html — the copy of the privacy policy you
// host for the Play Store listing — from the same text the app shows
// (lib/features/settings/privacy_policy.dart).
//
//   dart run tool/build_privacy_policy.dart
import 'dart:convert';
import 'dart:io';

import 'package:monthly_traq/app/app_info.dart';
import 'package:monthly_traq/features/settings/privacy_policy.dart';

void main() {
  const escape = HtmlEscape();
  final body = StringBuffer();
  for (final section in privacyPolicy) {
    body.writeln('    <h2>${escape.convert(section.heading)}</h2>');
    for (final paragraph in section.paragraphs) {
      body.writeln('    <p>${_linkEmail(escape.convert(paragraph))}</p>');
    }
    if (section.bullets.isNotEmpty) {
      body.writeln('    <ul>');
      for (final bullet in section.bullets) {
        body.writeln('      <li>${_linkEmail(escape.convert(bullet))}</li>');
      }
      body.writeln('    </ul>');
    }
  }

  final html =
      '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${AppInfo.name} Privacy Policy</title>
  <style>
    :root { --bg: #F4F5FA; --surface: #FFFFFF; --ink: #141726; --muted: #5E6475; --accent: #4338CA; --line: #E4E6EE; }
    @media (prefers-color-scheme: dark) {
      :root { --bg: #0D0F1A; --surface: #161927; --ink: #F2F3F8; --muted: #A0A5B5; --accent: #A9A5FF; --line: #262A3A; }
    }
    body { margin: 0; background: var(--bg); color: var(--ink); font: 16px/1.6 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }
    main { max-width: 720px; margin: 0 auto; padding: 48px 20px 64px; }
    .card { background: var(--surface); border: 1px solid var(--line); border-radius: 20px; padding: 8px 28px 28px; }
    h1 { font-size: 30px; line-height: 1.2; margin: 0 0 6px; letter-spacing: -0.02em; }
    .lead { color: var(--muted); margin: 0 0 28px; }
    h2 { font-size: 19px; margin: 28px 0 8px; }
    p, li { color: var(--muted); }
    ul { padding-left: 20px; }
    li { margin: 8px 0; }
    a { color: var(--accent); }
  </style>
</head>
<body>
  <main>
    <h1>${AppInfo.name} Privacy Policy</h1>
    <p class="lead">Effective ${AppInfo.privacyPolicyEffectiveDate}</p>
    <div class="card">
${body.toString().trimRight()}
    </div>
  </main>
</body>
</html>
''';

  File('store/privacy-policy.html')
    ..createSync(recursive: true)
    ..writeAsStringSync(html);
  stdout.writeln('Wrote store/privacy-policy.html');
}

String _linkEmail(String text) => text.replaceAll(
  AppInfo.supportEmail,
  '<a href="mailto:${AppInfo.supportEmail}">${AppInfo.supportEmail}</a>',
);
