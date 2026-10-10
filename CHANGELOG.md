# Changelog

All notable changes to MonthlyTraq. Versions match `version:` in
`pubspec.yaml` (the number in brackets is the Android build number), and
each release is tagged in git as `vX.Y.Z`.

## 1.9.5 (build 24) — 2026-10-10

### Added
- Investments (Profile → Money → Investments): add your PSX broker
  accounts with what you've put in and what they're worth, copied from
  your broker's app. See the value, what you put in, and your gain
  ("+Rs. 45,000 (+22.5%)"), with "Updated 3 days ago" so you know when to
  refresh it.
- Each account has Update (a new value), Put in, Take out and Dividend,
  a line showing how its value moved, and its full history. Money in and
  out can come from or go to your monthly money, a wallet, or just be
  recorded; deleting an entry undoes what it added.
- Net worth (Profile → Money → Net worth): what you own minus what you owe
  — your own money in wallets, savings goals, investments, and what's
  still owed on repayments — with a switch for each part. Your Home total
  balance can be added too; it starts switched off so the same money isn't
  counted twice.
- A Net worth card for Home, off by default — turn it on in Profile → Home
  screen layout.

### Changed
- The privacy policy covers investments.

## 1.9.4 (build 23) — 2026-10-10

### Added
- Savings goals (Profile → Money → Savings goals): save up for something —
  a mobile, a bike, a trip — with a target, what's already saved, an
  optional date to reach it by, and an icon.
- Each goal shows how much is saved ("Rs. 60,000 of Rs. 150,000 · 40%"),
  whether you're On track or Behind, and with a date, how much to save
  each month to reach it in time.
- Add money from your monthly money (it adds the expense in the category
  you pick), from a wallet, or just record it. Take money out into a wallet
  or just record it. Deleting an entry undoes it, including the expense or
  wallet entry it added.
- Reaching a goal celebrates it; mark it done once you've bought it and it
  moves to Done.
- A Savings goals card for Home, off by default — turn it on in Profile →
  Home screen layout.

### Changed
- The privacy policy covers savings goals.

## 1.9.3 (build 22) — 2026-10-10

### Added
- Repayments (Profile → Money → Repayments): track installments, loans and
  qisht — the total, what's already paid, and how often it's due (daily,
  monthly, every few months, yearly, or no deadline).
- The Repayments screen shows what's still owed and due this month, with
  each repayment's status (Due today, Due in 3 days, Overdue), progress
  ("12 of 24 paid") and what's left. Each one shows its next due date,
  payments left, when it'll be done, and every payment.
- Pay records a payment from your monthly money (it adds the expense in the
  category you pick — not-counted categories are listed first), from a
  wallet (it adds a "Spent" entry), or just records it. A full payment
  moves the due date to the next one. Deleting a payment undoes it,
  including the expense or wallet entry it added.
- A Repayments card for Home, off by default — turn it on in Profile →
  Home screen layout.

### Changed
- The privacy policy covers repayments.

## 1.9.1 (build 21) — 2026-10-10

### Added
- Wallets ask before saving Spent, Send back or Move for more than the
  wallet has ("Easypaisa has Rs. 8,000. Saving this takes it to
  −Rs. 1,000."), so a typo like 20,000 for 2,000 is caught.
- Closing a wallet sheet after typing something asks "Discard changes?"
  instead of losing it. These sheets no longer close with a swipe down.
- A wallet or person with a name you already have asks before saving.

## 1.9.0 (build 20) — 2026-10-05

### Added
- Wallets (Profile → Money → Wallets): track JazzCash, Easypaisa, your bank
  or cash, separately from your monthly budget. Nothing you record in a
  wallet shows in Transactions or counts as monthly income or spending.
- Each wallet has its own screen with its balance, split into Yours and
  Others' money, and buttons for Spent, Add, Received, Send back and Move
  (between wallets), plus an activity list. Tap any entry to edit or
  delete it; "Correct balance" fixes a wallet that doesn't match.
- Money you're keeping for others: record money someone gives you with
  Received. Each person has one running account. Spending never lowers
  what you owe them; only Send back does. Their screen shows what you're
  keeping, which wallets it's in, and the full history.
- A Wallets card for Home, off by default — turn it on in Profile → Home
  screen layout.

### Changed
- The privacy policy covers wallets and the people in them.

## 1.8.5 (build 19) — 2026-10-04

### Added
- Many more category icons — 135 in all, up from 37 — grouped into
  sections: Food & drink, Groceries & shopping, Transport, Bills & home,
  Health & care, Family & giving, Education & work, Fun & travel and Money.
  Includes everyday ones like a motorbike, rickshaw, gas cylinder,
  electricity, Wi-Fi, chai, biryani, cricket and a mosque for donations.

### Changed
- The New / Edit category sheet puts the name and budget switch at the
  top, scrolls the icons, and keeps the Add / Save button pinned at the
  bottom.

## 1.8.4 (build 18) — 2026-10-04

### Added
- "Count toward monthly budget" for expense categories (Profile →
  Categories → Edit). Turn it off for money that isn't budget spending —
  loan repayments, installments, savings. That spending still lowers your
  balance and shows in Spent, but doesn't use up your monthly budget or
  daily allowance.
- Under the budget bar, one line shows what wasn't counted ("Not counted:
  Rs. 61,300 · 2 categories"); tap it for the breakdown. Analytics and the
  Categories list mark these categories "Not in budget".

### Changed
- The category menu's "Rename & icon" is now "Edit".

### Fixed
- The New / Edit category sheet scrolls instead of overflowing at the
  bottom when the keyboard is open.

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
