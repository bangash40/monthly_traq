# Changelog

All notable changes to MonthlyTraq. Versions match `version:` in
`pubspec.yaml` (the number in brackets is the Android build number), and
each release is tagged in git as `vX.Y.Z`.

## 1.1.0 (build 2) — 2026-09-27

### Added
- Welcome screens on first launch, and a splash screen while the app loads.
- Google Sign-In, alongside email and password.
- Light and dark themes with 6 color styles, plus a System / Light / Dark
  switch on the Appearance screen.
- Redesigned Add screen: pick a category from an icon grid, then enter the
  amount on a calculator keypad that can add, subtract, multiply and divide.
  New categories can be created right from the grid.
- My Profile: set a profile photo (camera or gallery, cropped to a circle),
  view or remove it, and change your name.
- Category settings: add, rename, delete and reorder your categories.
- Default currency picker with search, showing each currency's code, symbol
  and country.
- Monthly start date: choose which day your budget month begins, for
  salaries that don't arrive on the 1st.
- Font size setting with 4 sizes that applies across the whole app.
- Browse past months on the Transactions and Analytics tabs.
- Transactions grouped by day with a daily total, and swipe-to-delete with
  an Undo button.
- Spending ring on Analytics; tap a category to see the expenses behind it.
- Helpful messages with a next step when a list is empty.
- App version shown at the bottom of Settings.

### Changed
- The Settings tab is now Profile, and settings are grouped into sections.
- New bottom navigation bar with a round Add button in the middle.
- Cleaner look: flat headers, consistent text sizes, and better contrast.
- Category colors use a 12-color set that avoids green and red, since those
  already mean income and expense. Existing categories are recolored once.
- Up to 100 categories (was 30), so adding one no longer hits the limit.
- After the welcome screens, the app opens on Sign up instead of Log in.

### Fixed
- Tapping a bottom navigation tab no longer leaves a grey box behind it.
- Your new name shows on the Profile tab straight away after you change it.
- Fruits uses a fruit basket icon instead of the Apple logo.

### Removed
- Reminder, Recurring Transactions and Data Sharing rows from Settings.

## 1.0.0 (build 1) — 2026-09-16

First release build.

- Sign up and log in with email and password; stays signed in between
  launches.
- Dashboard with your balance, this month's income and expense, and a
  monthly budget meter.
- Add, edit and delete transactions, with categories and search.
- Analytics with spending by category and a 6-month income and expense
  trend.
- Works offline and syncs when you're back online.
- Settings for monthly budget and currency, and sign out.
