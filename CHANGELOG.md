# Changelog

All notable changes to MonthlyTraq. Versions match `version:` in
`pubspec.yaml` (the number in brackets is the Android build number), and
each release is tagged in git as `vX.Y.Z`.

## 1.8.3 (build 17) — 2026-10-03

### Changed
- Numbers, bars and charts animate once per app launch — the first time
  each tab is opened — instead of every time you switch tabs. They still
  animate when something changes (a new transaction, another month).

### Fixed
- Home's numbers count up after the launch intro has faded away, so the
  count is actually visible; before, it played behind the intro.

## 1.8.2 (build 16) — 2026-10-03

### Added
- Tap the tab you're already on to scroll it back to the top. Switching
  tabs still keeps each one where you left it.

## 1.8.1 (build 15) — 2026-10-03

### Changed
- Sage, the default theme, is now listed first in Profile → Appearance.

## 1.8.0 (build 14) — 2026-10-03

Motion and feel. Every animation is short, plays once, and is skipped when
the phone's "Remove animations" setting is on.

### Added
- A launch intro: the splash's calendar page gets its spending donut swept
  on, then fades into the app once the first screen is ready.
- Numbers count up: the balance, income, spent, budget left, daily
  allowance, In / Out / Net and the Analytics total.
- Bars fill smoothly, and budget bars turn amber past 70% and red at 100%
  as they fill. Charts draw in: the Analytics donut sweeps round and the
  monthly and daily bars grow. They replay each time you open a tab.
- Saving a transaction shows "✓ Saved" on the button, and the new row
  glows for a moment in the list (Home scrolls to it).
- Haptic feedback: a light tick on keypad keys and categories, a firmer
  tap when you save, a strong one when you delete. Switch it off in
  Profile → General → Haptic feedback. It works even when the phone's own
  touch vibration is turned off.
- A month-end celebration: if last month ended under budget, Home shows a
  card with a burst of confetti for the first week of the new month.

### Changed
- Switching tabs fades the new tab in, and only the tab you tap is
  highlighted.

## 1.7.0 (build 13) — 2026-10-03

A new look: a new app icon, and Sage Light as the default.

### Added
- A new app icon, the "month donut": a calendar page with a spending donut
  on it — your month, and where its money goes. Drawn in Sage, and sized so
  no launcher shape clips it.
- `tool/render_icon.py`, which renders the icon images so they can be
  regenerated later.

### Changed
- The app now opens in the Sage theme, Light mode, whatever the phone's
  dark-mode setting. A theme or mode you already picked is kept.
- The splash screen shows the new icon on Sage's light background, so it
  flows straight into the first screen.
- The logo on the login and About screens is the new icon, in the current
  theme's color.

## 1.6.1 (build 12) — 2026-10-01

### Changed
- In Profile, the Data section (Backup, Clear cache, Delete all data,
  Delete account) now comes after More, just above Log out.

### Removed
- The version label at the bottom of Profile. The full version is in
  Profile → More → About.

## 1.6.0 (build 11) — 2026-10-01

Make Home your own. Out of the box it looks exactly as before; the new
extras are switches you can turn on.

### Added
- Home screen layout (Profile → Appearance): show or hide each Home card
  and drag them into the order you like. Reset to default puts Home back.
- A Daily allowance card, off by default: how much you can spend today and
  still stay on budget, with a bar for what you've spent today. Spend less
  and tomorrow's amount goes up; spend more and it goes down.
- A Privacy button, off by default: an eye on the balance card that
  changes every amount on Home to "Rs. ••••". Other screens still show
  real numbers.

## 1.5.0 (build 10) — 2026-10-01

### Added
- An About screen (Profile → More → About) with the app logo in your
  theme's color, the app name, and the full version with the build number,
  e.g. "Version 1.5.0 (10)".

### Changed
- The About section in Profile is now called More.

## 1.4.4 (build 9) — 2026-10-01

### Removed
- The Open-source licenses row from Profile → About.
- Placeholder rows for features that aren't planned for now (they only
  ever showed in debug builds): Cash books, Accounts, Number format,
  Calendar, Export data, Import transactions, API access and Password.

## 1.4.3 (build 8) — 2026-10-01

### Changed
- The + (add transaction) button now sits inside the bottom bar as a
  filled rounded button, instead of floating above it. It no longer covers
  the bottom of lists and screens, and the bar's five slots are evenly
  spaced.

## 1.4.2 (build 7) — 2026-10-01

### Fixed
- The "Transaction deleted · Undo" message now disappears on its own after
  5 seconds instead of staying on screen until tapped.
- If deleting or restoring a transaction fails, the message is now plain
  language instead of raw error text.

## 1.4.1 (build 6) — 2026-09-30

### Fixed
- The back button now works like other Android apps: on Transactions,
  Analytics or Profile it takes you to Home, and on Home it leaves the app.
  Before, back on any tab closed the app straight away.

## 1.4.0 (build 5) — 2026-09-29

Friendlier, safer sign-up and login.

### Added
- A password strength bar on sign-up (Weak / Okay / Strong) with a one-line
  tip. Passwords need 8 or more characters; common ones ("password123",
  "P@ssw0rd!", "12345678"), easy patterns and your own name or email are
  turned away.
- A Confirm password field on sign-up.
- "Did you mean ali@gmail.com?" under the email field when the address
  looks misspelled (gmial.com, gmail.con, hotmail, test.om…). One tap fixes
  it.
- Sign-up turns away placeholder addresses (example.com, test.com, test.om,
  fake.net…) and temporary-inbox services (Mailinator, YOPmail and others),
  since they can't receive a password-reset email. Logging in to existing
  accounts is unchanged.

### Changed
- Stricter email format checks (no spaces, one @, a proper ending).
- Clear, plain-language messages for every login, sign-up, password reset,
  Google sign-in and Delete account error, instead of raw Firebase text.
- Form errors wrap onto a second line instead of being cut off.
- "New to MonthlyTraq? Create account" and "Already have an account? Log
  in" sit right under the buttons instead of being pinned to the bottom of
  the screen.

### Fixed
- The app crashed when the Delete account password box closed.

## 1.3.0 (build 4) — 2026-09-28

Getting ready for the Play Store.

### Added
- Delete account (Profile → Data). After you confirm and re-enter your
  password (or pick your Google account), it permanently deletes your
  transactions, categories, budget, profile photo and sign-in.
- An About section in Profile: the privacy policy, Contact support (opens
  your email app), Rate MonthlyTraq (opens the Play Store listing) and
  Open-source licenses.
- A hosted copy of the privacy policy for the Play Store listing
  (`store/privacy-policy.html`, generated from the same text the app shows
  by `dart run tool/build_privacy_policy.dart`).

### Changed
- The app's package name is now `com.monthlytraq.app` on every platform.
  Android treats this as a new app, so the old version has to be
  uninstalled and you sign in again once.
- Release builds hide settings that don't do anything yet: rows marked
  "Soon" or "Pro", Quick-add notification and Sound effects. Debug builds
  still show them.

## 1.2.0 (build 3) — 2026-09-28

A full redesign, following the MonthlyTraq design spec: numbers lead,
surfaces stay quiet, one brand color per theme marks what you can tap, and
green always means income and red always means spending.

### Added
- Seven themes, each with a light and a dark version: Indigo (the new
  default), Ocean, Sage, Plum, Rose, Saffron and Graphite. The Appearance
  screen previews each one.
- The Manrope typeface throughout, with amounts that line up in columns.
- Home: a greeting, your balance with this month's income and spending, a
  budget card showing what's left and how many days remain, and your top 3
  spending categories.
- Transactions: In / Out / Net totals for the month. Category filters only
  list categories used that month, and search also matches category names.
- Analytics: switch between Spending and Income, see how the month compares
  with the one before, and see your daily average and biggest day.
- Category detail: the category's share of the month, a by-day chart, and
  the time of each transaction.
- Add screen: everything on one screen. The calculation shows above a live
  result, with chips for the date and a note, and More / New tiles for
  categories.
- A Monthly budget sheet with the reset day right beside it, and a day grid
  for picking when your month starts.
- A category editor with 38 icons to choose from.
- "Forgot?" on the login screen now emails a password reset link.
- "Delete all data" removes all your transactions, after asking first.
- The Thousands separator setting now works. Quick-add notification and
  Sound effects are remembered (the features themselves are coming later).

### Changed
- The Profile tab now holds every setting in one grouped list. Features that
  aren't built yet are marked "Soon" and can't be tapped; paid-tier ones are
  marked PRO.
- New onboarding illustrations, a progress bar, and a "Log in" link for
  people who already have an account.
- Redesigned login and sign-up screens, with clearer error messages and a
  live password-length check.
- The app icon and splash screen are now Indigo.
- Your theme choice resets to Indigo once, because the list of themes
  changed.

### Fixed
- Typing "." right after + − × ÷ on the keypad no longer breaks the
  calculation.
- The "Undo" button on snackbars is now readable in every theme and mode.
- Spending by category now includes transactions without a category (as
  "Uncategorized"), so the rows always add up to the total.

### Removed
- VIP badges (replaced by "Soon" and PRO), and the separate Settings and
  Font Size screens (merged into Profile and Appearance).

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
