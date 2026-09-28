# MonthlyTraq

A personal budgeting app for Android, built with Flutter and Firebase. Log
income and expenses in seconds, see where your money goes each month, and
keep spending under a monthly budget that resets on the day you choose.

Current version: **1.2.0** — see [CHANGELOG.md](CHANGELOG.md).

## Features

- **Quick entry** — one screen with a calculator keypad (`+ − × ÷`, evaluated
  live), a category grid, a date and an optional note.
- **Home** — total balance, this month's income and spending, a budget meter
  that turns amber past 70% and red when you're over, top spending
  categories and recent transactions.
- **Transactions** — grouped by day with daily totals; search, filter by
  category, swipe to delete with Undo, and step back through past months.
- **Analytics** — spending or income by category (donut and bars), change
  vs the previous month, daily average, biggest day, and a 6-month trend.
  Tap a category for its by-day chart and transactions.
- **Budget cycles** — the month can start on any day (1–31) to match your
  payday; days past a month's end fall back to its last day.
- **Categories** — 27 expense and 5 income categories to start; add, rename,
  change icon, reorder by dragging, or delete (transactions are kept as
  "Uncategorized").
- **Appearance** — 7 themes (Indigo, Ocean, Sage, Plum, Rose, Saffron,
  Graphite), each with light and dark modes, plus 4 text sizes.
- **Accounts** — email/password or Google sign-in, password reset, profile
  name and photo.
- **Currency** — pick from 33 currencies; the thousands separator can be
  turned off.
- **Offline-friendly** — works offline from Firestore's local cache and syncs
  when back online.

## Tech stack

| Area | Choice |
| --- | --- |
| App | Flutter 3.47 · Dart 3.13 · Material 3 |
| State | [provider](https://pub.dev/packages/provider) (`ChangeNotifier`) |
| Auth | Firebase Authentication (email/password, Google) |
| Data | Cloud Firestore with offline persistence |
| Local settings | shared_preferences |
| Profile photos | image_picker + image_cropper, stored compressed in Firestore |
| Typeface | Manrope, bundled (SIL Open Font License, `assets/fonts/OFL.txt`) |

Charts are drawn with `CustomPainter` — there's no charting dependency.

## Project structure

```
lib/
  main.dart              Firebase + Google Sign-In setup, runs the app
  app/                   App shell and design system
    app.dart             Providers and MaterialApp
    theme.dart           The 7 themes, colors, radii (AppColors via context.colors)
    text_styles.dart     Type scale (AppText)
    money.dart           Amount formatting (context.money)
    theme_controller.dart, app_settings.dart   Saved appearance and preferences
    main_shell.dart      Bottom navigation and the add button
  features/              One folder per area: auth, onboarding, dashboard,
                         transactions, analytics, settings
  services/
    transactions_repository.dart   Live Firestore data for the signed-in user
    budget_cycle.dart    Budget-month maths (custom start day, clamping)
    cycle_stats.dart     Totals, breakdowns, daily figures, trends
    calculator.dart      The keypad's expression input
    auth_service.dart    Sign-in, sign-up, password reset
  models/                Transaction, category, onboarding slide
  widgets/               Shared UI (ui.dart), rows, charts, sheets
  dev/sample_data.dart   Debug-only sample transactions
test/                    Unit and widget tests
firestore.rules          Security rules for Firestore
```

## Getting started

### Prerequisites

- Flutter 3.47+ (`flutter --version`)
- Android Studio or the Android SDK, and a device or emulator
- A Firebase project, and the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup)
  (`dart pub global activate flutterfire_cli`)

### 1. Install packages

```bash
flutter pub get
```

### 2. Connect Firebase

The Firebase config files hold your project's keys, so they're
**gitignored and not in this repo**. Generate them for your own project:

```bash
flutterfire configure
```

This creates `lib/firebase_options.dart` and
`android/app/google-services.json`. Then, in the Firebase console:

1. **Authentication → Sign-in method:** enable **Email/Password** and **Google**.
2. **Firestore Database:** create a database, then publish the rules from
   [`firestore.rules`](firestore.rules) (Firestore → Rules).
3. **Project settings → Your apps → Android:** add your debug and release
   SHA-1 fingerprints (`cd android && ./gradlew signingReport`). Google
   sign-in fails without them.
4. Set `serverClientId` in `lib/main.dart` to your project's **Web** OAuth
   client ID (Google Cloud console → Credentials). It's a public identifier,
   not a secret.

### 3. Run

```bash
flutter run
```

Debug builds add a **Developer** section at the bottom of the Profile tab
with **Load sample data** — about six months of realistic transactions —
and **Remove sample data**, which deletes only those.

## Tests

```bash
flutter analyze
flutter test
```

The tests cover budget-cycle maths, statistics, the calculator, money
formatting, the shared widgets, and WCAG contrast (4.5:1) for all 14
theme palettes.

## Release build

Release signing reads `android/key.properties`, which is gitignored along
with the keystore itself:

```properties
storePassword=…
keyPassword=…
keyAlias=…
storeFile=your-release-key.jks   # relative to android/app
```

Without it, release builds fall back to debug signing. Then:

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

> A release build and a debug build are signed with different keys, so
> Android won't install one over the other. It has to uninstall first,
> which signs you out on that device. Your data is safe in Firestore.

## Versioning

Versions follow `version:` in `pubspec.yaml` (`1.2.0+3` = version 1.2.0,
Android build 3; the build number must increase every release). Each release
adds an entry to [CHANGELOG.md](CHANGELOG.md) and is tagged `vX.Y.Z` in git.

## Data model

Everything lives under the signed-in user, so each user can only read and
write their own data (enforced by `firestore.rules`):

```
users/{uid}                    monthlyBudget, monthStartDay, currencySymbol,
                               currencyCode, photoBase64
users/{uid}/transactions/{id}  title, amount, type, categoryId, date, note
users/{uid}/categories/{id}    name, iconKey, color, type, sortOrder, createdAt
```

## Not in this repo

These are kept locally and are gitignored: design and planning documents
(`Docs/`, `PRD.md`, `TRD.md`), Firebase config files, signing keys and
`key.properties`, and any `.env` or secret files.
