// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageSystem => 'System default';

  @override
  String get languageTitle => 'Language';

  @override
  String get badgeSoon => 'Soon';

  @override
  String get badgePro => 'PRO';

  @override
  String get back => 'Back';

  @override
  String get appLogo => 'MonthlyTraq logo';

  @override
  String comingSoonLabel(String label) {
    return '$label, coming soon';
  }

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orDivider => 'or';

  @override
  String get emailHint => 'you@example.com';

  @override
  String emailSuggestionLabel(String email) {
    return 'Did you mean $email? Tap to use it.';
  }

  @override
  String get emailSuggestionBefore => 'Did you mean ';

  @override
  String get emailSuggestionAfter => '?';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get backToThisMonth => 'Back to this month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get about => 'About';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutTagline => 'Track your income, expenses and monthly budget.';

  @override
  String couldNotSave(String error) {
    return 'Could not save: $error';
  }

  @override
  String get monthStartsOn => 'Month starts on';

  @override
  String get monthStartsOnHelp =>
      'Pick the day your budget resets — usually your payday.';

  @override
  String get monthStartsOnShortMonths =>
      'In shorter months, 29–31 fall back to the month\'s last day.';

  @override
  String get transactionDeleteFailed =>
      'Couldn\'t delete the transaction. Please try again.';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get undo => 'Undo';

  @override
  String get transactionRestoreFailed =>
      'Couldn\'t bring the transaction back. Please try again.';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String trendChartLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Income and spending, last $count months',
      one: 'Income and spending, last month',
    );
    return '$_temp0';
  }

  @override
  String get budgetAmountError => 'Enter an amount, or 0 for no budget';

  @override
  String budgetSaveFailed(String error) {
    return 'Could not save budget: $error';
  }

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get budgetSheetHelp =>
      'How much you plan to spend each cycle. The meter on Home fills as you go.';

  @override
  String budgetResetsOn(String day) {
    return 'Resets on the $day';
  }

  @override
  String get budgetMatchPayday => 'Match it to your payday';

  @override
  String get change => 'Change';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get categoryLimitReached => 'You\'ve reached the category limit';

  @override
  String get categoryNameError => 'Give the category a name';

  @override
  String categorySaveFailed(String error) {
    return 'Could not save category: $error';
  }

  @override
  String categoryAddFailed(String error) {
    return 'Could not add category: $error';
  }

  @override
  String get editCategory => 'Edit category';

  @override
  String get newCategory => 'New category';

  @override
  String get name => 'Name';

  @override
  String get categoryNameHintIncome => 'e.g. Freelance';

  @override
  String get categoryNameHintExpense => 'e.g. Groceries';

  @override
  String get countTowardBudget => 'Count toward monthly budget';

  @override
  String get countTowardBudgetOn =>
      'Spending here uses up your monthly budget.';

  @override
  String get countTowardBudgetOff =>
      'Not in budget — for loan repayments, savings and the like. Still lowers your balance.';

  @override
  String get icon => 'Icon';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get addCategory => 'Add category';

  @override
  String get iconGroupGeneral => 'General';

  @override
  String get iconGroupFood => 'Food & drink';

  @override
  String get iconGroupShopping => 'Groceries & shopping';

  @override
  String get iconGroupTransport => 'Transport';

  @override
  String get iconGroupBills => 'Bills & home';

  @override
  String get iconGroupHealth => 'Health & care';

  @override
  String get iconGroupFamily => 'Family & giving';

  @override
  String get iconGroupWork => 'Education & work';

  @override
  String get iconGroupFun => 'Fun & travel';

  @override
  String get iconGroupMoney => 'Money';

  @override
  String get tabHome => 'Home';

  @override
  String get tabTransactions => 'Transactions';

  @override
  String get tabAnalytics => 'Analytics';

  @override
  String get tabProfile => 'Profile';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get backOnline => 'Back online';

  @override
  String get youreOffline => 'You\'re offline';

  @override
  String get offlineMessage =>
      'You\'re offline. Changes will sync when you\'re back.';

  @override
  String get savedOffline =>
      'Saved on your phone. It\'ll sync when you\'re back online.';

  @override
  String get onboardingTitleTransactions => 'Every rupee, in one place';

  @override
  String get onboardingBodyTransactions =>
      'Log income and expenses in seconds, sorted by category.';

  @override
  String get onboardingTitleBreakdown => 'See where it goes';

  @override
  String get onboardingBodyBreakdown =>
      'A clear breakdown shows what you spend on, and how much.';

  @override
  String get onboardingTitleBudget => 'A budget that keeps up';

  @override
  String get onboardingBodyBudget =>
      'Set a monthly limit and watch the meter fill as you spend.';

  @override
  String get onboardingTitleTrends => 'Spot your trends';

  @override
  String get onboardingBodyTrends =>
      'Compare what comes in and goes out, month by month.';

  @override
  String get onboardingTitleSync => 'Safe in your account';

  @override
  String get onboardingBodySync =>
      'Everything syncs to your account, so it\'s there on any device.';

  @override
  String get authFailedLogIn => 'Couldn\'t log you in.';

  @override
  String get authFailedSignUp => 'Couldn\'t create your account.';

  @override
  String get authFailedGoogle => 'Couldn\'t sign in with Google.';

  @override
  String get authFailedReset => 'Couldn\'t send the reset email.';

  @override
  String get authFailedConfirm => 'Couldn\'t confirm it\'s you.';

  @override
  String get authFailedDelete => 'Couldn\'t delete your account.';

  @override
  String authTryAgain(String failed) {
    return '$failed Please try again.';
  }

  @override
  String get authGoogleInterrupted =>
      'Google sign-in was interrupted. Please try again.';

  @override
  String get authGoogleWrongAccount =>
      'Choose the Google account you signed up with.';

  @override
  String get authGoogleUnavailable =>
      'Google sign-in isn\'t available right now. Use your email instead.';

  @override
  String get authNoInternet =>
      'No internet connection. Check your connection and try again.';

  @override
  String get authTooManyAttempts =>
      'Too many attempts. Wait a few minutes, then try again.';

  @override
  String get authInvalidEmail => 'That email address doesn\'t look right.';

  @override
  String get authMissingEmail => 'Enter your email address.';

  @override
  String get authMissingPassword => 'Enter your password.';

  @override
  String authUserDisabled(String email) {
    return 'This account has been turned off. Contact $email for help.';
  }

  @override
  String get authEmailInUse =>
      'That email already has an account. Log in instead.';

  @override
  String get authWeakPassword => 'Choose a stronger password.';

  @override
  String get authExistsWithPassword =>
      'That email already has an account. Log in with your email and password.';

  @override
  String get authUserMismatch =>
      'That doesn\'t match the account you\'re signed in with.';

  @override
  String get authWrongLogin =>
      'That email and password don\'t match an account.';

  @override
  String get authWrongPassword => 'That password isn\'t right.';

  @override
  String get authLogInAgain =>
      'For your security, log out and back in, then try again.';

  @override
  String get authMethodUnavailable =>
      'This way of signing in isn\'t available right now.';

  @override
  String get authBusy => 'We\'re busy right now. Please try again later.';

  @override
  String get emailInvalid =>
      'Enter a valid email address, like name@example.com';

  @override
  String get emailRequired => 'Enter your email address';

  @override
  String get emailHasSpaces => 'An email address can\'t have spaces';

  @override
  String get emailPlaceholder =>
      'Use your real email address — you\'ll need it if you forget your password';

  @override
  String get emailTemporary =>
      'Temporary emails can\'t be used — you\'ll need a real one if you forget your password';

  @override
  String get passwordSpaceAtEnds =>
      'A password can\'t start or end with a space';

  @override
  String passwordTooShort(int count) {
    return 'Use at least $count characters';
  }

  @override
  String get passwordOnlyNumbers =>
      'Add some letters — numbers alone are easy to guess';

  @override
  String get passwordTooCommon =>
      'This password is too common. Try something harder to guess';

  @override
  String get passwordPersonal =>
      'Don\'t use your name or email in your password';

  @override
  String get passwordRequired => 'Create a password';

  @override
  String get forgotNeedsEmail =>
      'Enter your email above, then tap Forgot? again.';

  @override
  String resetLinkSent(String email) {
    return 'If $email has an account, a reset link is on its way.';
  }

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in to keep tracking your month.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot?';

  @override
  String get passwordHintLogin => 'Your password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordEnter => 'Enter your password';

  @override
  String get logIn => 'Log in';

  @override
  String get newToApp => 'New to MonthlyTraq?';

  @override
  String get createAccount => 'Create account';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get signupSubtitle => 'It takes less than a minute.';

  @override
  String get fullName => 'Full name';

  @override
  String get yourName => 'Your name';

  @override
  String get nameRequired => 'Enter your name';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordAgain => 'Type your password again';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String passwordStrengthEmpty(int count) {
    return 'Use $count or more characters. A short phrase is easy to remember and hard to guess.';
  }

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordOkay => 'Okay';

  @override
  String get passwordOkayHint => 'Good. A longer password is even stronger.';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get passwordStrongHint => 'Great password.';

  @override
  String passwordStrengthLabel(String strength, String hint) {
    return 'Password strength: $strength. $hint';
  }

  @override
  String onboardingStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get started';

  @override
  String get continueButton => 'Continue';

  @override
  String get sampleGroceries => 'Groceries';

  @override
  String get sampleSalary => 'Salary';

  @override
  String get sampleBusPass => 'Bus pass';

  @override
  String get sampleLeft => 'left';

  @override
  String percentUsed(int percent) {
    return '$percent% used';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get sampleBackedUp => 'Backed up';

  @override
  String get sampleJustNow => 'Just now';

  @override
  String get sampleFood => 'Food';

  @override
  String get sampleShopping => 'Shopping';

  @override
  String get sampleEntertainment => 'Entertainment';

  @override
  String get sampleTransport => 'Transport';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your account and everything in it: your transactions, categories, budget and profile photo. This can\'t be undone.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deletingAccount => 'Deleting your account…';

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get confirmItsYou => 'Confirm it\'s you';

  @override
  String get confirmPasswordToDelete =>
      'Enter your password to delete your account.';

  @override
  String get homeCardBalance => 'Balance';

  @override
  String get homeCardBalanceAbout =>
      'Your balance, with this month\'s income and spending';

  @override
  String get homeCardWallets => 'Wallets';

  @override
  String get homeCardWalletsAbout =>
      'What\'s in your wallets, and money you\'re keeping for others. Shows once you add a wallet.';

  @override
  String get homeCardRepayments => 'Repayments';

  @override
  String get homeCardRepaymentsAbout =>
      'What\'s due next on money you owe. Shows once you add a repayment.';

  @override
  String get homeCardGoals => 'Savings goals';

  @override
  String get homeCardGoalsAbout =>
      'How close you are to what you\'re saving for. Shows once you add a goal.';

  @override
  String get homeCardNetWorth => 'Net worth';

  @override
  String get homeCardNetWorthAbout =>
      'What you own minus what you owe: wallets, goals, investments and repayments together.';

  @override
  String get homeCardBudget => 'Monthly budget';

  @override
  String get homeCardBudgetAbout => 'How much of your budget is left';

  @override
  String get homeCardDailyAllowance => 'Daily allowance';

  @override
  String get homeCardDailyAllowanceAbout =>
      'How much you can spend today and stay on budget. Needs a monthly budget.';

  @override
  String get homeCardTopSpending => 'Top spending';

  @override
  String get homeCardTopSpendingAbout =>
      'Your three biggest categories this month';

  @override
  String get homeCardRecent => 'Recent';

  @override
  String get homeCardRecentAbout => 'Your latest transactions';

  @override
  String get homeScreenLayout => 'Home screen layout';

  @override
  String get homeLayoutHelp =>
      'Choose which cards show on Home, and drag the handle to change their order.';

  @override
  String get balanceCardSection => 'Balance card';

  @override
  String get privacyButton => 'Privacy button';

  @override
  String get privacyButtonAbout =>
      'Adds an eye button to the balance card that hides your amounts on Home.';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String dragToReorder(String card) {
    return 'Drag to reorder $card';
  }

  @override
  String get modeSystem => 'System';

  @override
  String get modeLight => 'Light';

  @override
  String get modeDark => 'Dark';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeDefault => 'Default';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get fontSizeLargest => 'Largest';

  @override
  String get appearance => 'Appearance';

  @override
  String get mode => 'Mode';

  @override
  String get theme => 'Theme';

  @override
  String get textSize => 'Text size';

  @override
  String textSizePreview(String amount) {
    return 'Groceries · $amount — this is how text will look.';
  }

  @override
  String themeCardLabel(String name) {
    return '$name theme';
  }

  @override
  String get currency => 'Currency';

  @override
  String get currencySearchHint => 'Search by name, code or country';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noMatchingCurrency => 'No matching currency';

  @override
  String get choosePhotoFrame => 'Choose photo frame';

  @override
  String get photoTooLarge =>
      'That photo is too large — please choose one under 1MB.';

  @override
  String photoUpdateFailed(String error) {
    return 'Could not update photo: $error';
  }

  @override
  String photoRemoveFailed(String error) {
    return 'Could not remove photo: $error';
  }

  @override
  String get viewPhoto => 'View photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get emailCantChange => 'Your sign-in email can\'t be changed here.';

  @override
  String noEmailApp(String email) {
    return 'No email app found. Write to $email';
  }

  @override
  String get playStoreFailed => 'Couldn\'t open the Play Store';

  @override
  String get automaticBackup => 'Automatic backup';

  @override
  String get automaticBackupBody =>
      'Everything you log is saved to your MonthlyTraq account as you go, so it\'s there on any device you sign in on. Changes made offline upload once you\'re back online.';

  @override
  String get gotIt => 'Got it';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get noTransactionsToDelete => 'There are no transactions to delete';

  @override
  String get deleteAllDataTitle => 'Delete all data?';

  @override
  String deleteAllDataBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return 'This permanently deletes all $_temp0 on your account. Your categories and settings are kept. This can\'t be undone.';
  }

  @override
  String get deleteAll => 'Delete all';

  @override
  String deletedTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deleted $count transactions',
      one: 'Deleted 1 transaction',
    );
    return '$_temp0';
  }

  @override
  String couldNotDelete(String error) {
    return 'Could not delete: $error';
  }

  @override
  String get budgetSection => 'Budget';

  @override
  String get notSet => 'Not set';

  @override
  String get moneySection => 'Money';

  @override
  String get netWorth => 'Net worth';

  @override
  String get wallets => 'Wallets';

  @override
  String get add => 'Add';

  @override
  String walletCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wallets',
      one: '1 wallet',
    );
    return '$_temp0';
  }

  @override
  String get repayments => 'Repayments';

  @override
  String repaymentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repayments',
      one: '1 repayment',
    );
    return '$_temp0';
  }

  @override
  String get savingsGoals => 'Savings goals';

  @override
  String goalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goals',
      one: '1 goal',
    );
    return '$_temp0';
  }

  @override
  String get investments => 'Investments';

  @override
  String get layoutDefault => 'Default';

  @override
  String get layoutCustom => 'Custom';

  @override
  String get appIcon => 'App icon';

  @override
  String get generalSection => 'General';

  @override
  String get categories => 'Categories';

  @override
  String get hapticFeedback => 'Haptic feedback';

  @override
  String get numbersSection => 'Numbers & tools';

  @override
  String get thousandsSeparator => 'Thousands separator';

  @override
  String get calculator => 'Calculator';

  @override
  String get notificationsSection => 'Notifications & sound';

  @override
  String get quickAddNotification => 'Quick-add notification';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get advancedSection => 'Advanced';

  @override
  String get aiSettings => 'AI settings';

  @override
  String get moreSection => 'More';

  @override
  String get contactSupport => 'Contact support';

  @override
  String rateApp(String app) {
    return 'Rate $app';
  }

  @override
  String get dataSection => 'Data';

  @override
  String get backup => 'Backup';

  @override
  String get backupAutomatic => 'Automatic';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get logOut => 'Log out';

  @override
  String get addYourName => 'Add your name';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get seeAll => 'See all';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get noTransactionsYetHome =>
      'Log what you spend and earn and it shows up here, grouped by day.';

  @override
  String get addFirstTransaction => 'Add your first transaction';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get showAmounts => 'Show amounts';

  @override
  String get hideAmounts => 'Hide amounts';

  @override
  String get income => 'Income';

  @override
  String get spent => 'Spent';

  @override
  String get overBudget => 'Over budget';

  @override
  String get edit => 'Edit';

  @override
  String get setBudget => 'Set budget';

  @override
  String get setBudgetPrompt =>
      'Set a budget to see how much is left this month.';

  @override
  String amountOver(String amount) {
    return '$amount over';
  }

  @override
  String budgetOverTail(String budget) {
    return 'your $budget budget';
  }

  @override
  String budgetLeftTail(String budget) {
    return 'left of $budget';
  }

  @override
  String get budgetUsed => 'Budget used';

  @override
  String percentValue(int percent) {
    return '$percent percent';
  }

  @override
  String get lastDayOfCycle => 'Last day of this cycle';

  @override
  String daysLeftInCycle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left in cycle',
      one: '1 day left in cycle',
    );
    return '$_temp0';
  }

  @override
  String allowanceOverTail(String amount) {
    return 'today\'s $amount';
  }

  @override
  String get allowanceLeftTail => 'left to spend today';

  @override
  String get allowanceUsedUp =>
      'You\'ve used this cycle\'s budget. Anything more goes over it.';

  @override
  String get allowanceTomorrowLower =>
      'Tomorrow\'s allowance will be a little lower to stay on budget.';

  @override
  String get lastDay => 'Last day';

  @override
  String get noBudgetLeft => 'No budget left';

  @override
  String get allowanceUsed => 'Today\'s allowance used';

  @override
  String spentToday(String amount) {
    return 'Spent $amount today';
  }

  @override
  String perDay(String amount) {
    return '$amount a day';
  }

  @override
  String yoursAndOthers(String yours, String others) {
    return 'Yours $yours · Others\' $others';
  }

  @override
  String get allYours => 'All yours';

  @override
  String get lastCycle => 'Last cycle';

  @override
  String underBudget(String name) {
    return '$name — under budget!';
  }

  @override
  String budgetWinBody(String left, String budget) {
    return 'You kept $left of your $budget budget. Nice work.';
  }

  @override
  String get dismiss => 'Dismiss';

  @override
  String notCountedOne(String category, String amount) {
    return 'Not counted: $category · $amount';
  }

  @override
  String notCountedMany(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '1 category',
    );
    return 'Not counted: $amount · $_temp0';
  }

  @override
  String showDetailsLabel(String summary) {
    return '$summary. Show details';
  }

  @override
  String get notInYourBudget => 'Not in your budget';

  @override
  String get notInBudgetHelp =>
      'This month\'s spending in these categories lowers your balance and shows in Spent, but doesn\'t use up your monthly budget.';

  @override
  String get total => 'Total';

  @override
  String get notInBudgetHowToChange =>
      'To change which categories count, go to Profile → Categories → Edit.';

  @override
  String deleteNamed(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteCategoryBody =>
      'Transactions in this category are kept and become uncategorized.';

  @override
  String get delete => 'Delete';

  @override
  String couldNotReorder(String error) {
    return 'Could not reorder: $error';
  }

  @override
  String expenseCount(int count) {
    return 'Expense · $count';
  }

  @override
  String incomeCount(int count) {
    return 'Income · $count';
  }

  @override
  String get categoriesHelp =>
      'Drag to reorder. The order here is the order in the add screen.';

  @override
  String get noExpenseCategories => 'No expense categories';

  @override
  String get noIncomeCategories => 'No income categories';

  @override
  String get noCategoriesHelp => 'Add one to start sorting what you log.';

  @override
  String get notInBudget => 'Not in budget';

  @override
  String optionsFor(String name) {
    return 'Options for $name';
  }

  @override
  String get deleteEllipsis => 'Delete…';

  @override
  String get spending => 'Spending';

  @override
  String noSpendingIn(String month) {
    return 'No spending in $month';
  }

  @override
  String noIncomeIn(String month) {
    return 'No income in $month';
  }

  @override
  String get noSpendingHelp =>
      'Expenses you log are broken down by category here.';

  @override
  String get noIncomeHelp => 'Income you log is broken down by category here.';

  @override
  String get earned => 'Earned';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get biggestDay => 'Biggest day';

  @override
  String get lastSixMonths => 'Last 6 months';

  @override
  String get moneyIn => 'In';

  @override
  String get moneyOut => 'Out';

  @override
  String sameAs(String month) {
    return 'Same as $month';
  }

  @override
  String percentVersus(int percent, String month) {
    return '$percent% vs $month';
  }

  @override
  String shareOfSpending(int share, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$share% of spending · $_temp0';
  }

  @override
  String shareOfIncome(int share, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$share% of income · $_temp0';
  }

  @override
  String get byDay => 'By day';

  @override
  String nothingIn(String month) {
    return 'Nothing in $month';
  }

  @override
  String get categoryEmptyHelp => 'Transactions in this category show up here.';

  @override
  String get searchTransactions => 'Search transactions';

  @override
  String get all => 'All';

  @override
  String get noMatches => 'No matches';

  @override
  String get noMatchesHelp =>
      'Nothing this month matches your search or filter.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String nothingLoggedIn(String month) {
    return 'Nothing logged in $month';
  }

  @override
  String get net => 'Net';

  @override
  String get amountAboveZero => 'Enter an amount above zero';

  @override
  String get pickCategory => 'Pick a category';

  @override
  String get close => 'Close';

  @override
  String get expense => 'Expense';

  @override
  String get amount => 'Amount';

  @override
  String get addNote => 'Add a note';

  @override
  String get category => 'Category';

  @override
  String get saveIncome => 'Save income';

  @override
  String get saveExpense => 'Save expense';

  @override
  String get more => 'More';

  @override
  String get newLabel => 'New';

  @override
  String get keyDivide => 'Divide';

  @override
  String get keyMultiply => 'Multiply';

  @override
  String get keyMinus => 'Minus';

  @override
  String get keyPlus => 'Plus';

  @override
  String get keyDecimal => 'Decimal point';

  @override
  String get keyDeleteDigit => 'Delete digit';

  @override
  String get saved => 'Saved';

  @override
  String get note => 'Note';

  @override
  String get noteHelp =>
      'Shown as the transaction\'s name. Leave it empty to use the category name.';

  @override
  String get noteHint => 'e.g. Groceries at Imtiaz';

  @override
  String get done => 'Done';

  @override
  String get frequencyDaily => 'Daily';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyEveryMonths => 'Every few months';

  @override
  String get frequencyYearly => 'Yearly';

  @override
  String get frequencyNone => 'No deadline';

  @override
  String get dueToday => 'Due today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String overdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Overdue $count days',
      one: 'Overdue 1 day',
    );
    return '$_temp0';
  }

  @override
  String dueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Due in $count days',
      one: 'Due in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get paidOff => 'Paid off';

  @override
  String get goalReached => 'Reached';

  @override
  String get goalOnTrack => 'On track';

  @override
  String get goalBehind => 'Behind';

  @override
  String get goalDatePassed => 'Date passed';

  @override
  String get goalNoDate => 'No date';

  @override
  String get goalDone => 'Done';

  @override
  String get stillOwed => 'Still owed';

  @override
  String get netWorthWalletsAbout => 'Your own money in them, not others\'';

  @override
  String get netWorthGoalsAbout =>
      'Money moved into goals from monthly money or a wallet';

  @override
  String get netWorthInvestmentsAbout => 'What your accounts are worth now';

  @override
  String get netWorthBalanceAbout => 'Income minus spending, from Home';

  @override
  String get netWorthOwedAbout => 'What\'s left to pay on repayments';

  @override
  String get noInternetTryAgain =>
      'No internet connection. Try again when you\'re back online.';

  @override
  String get couldntSaveTryAgain => 'Couldn\'t save. Please try again.';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesBody => 'What you typed here won\'t be saved.';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get whichWallet => 'Which wallet?';

  @override
  String get noWallet => 'No wallet';

  @override
  String get whoseMoney => 'Whose money?';

  @override
  String get someoneNewHint => 'Someone new, e.g. Ahmed';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get notCounted => 'Not counted';

  @override
  String get netWorthTagline => 'What you own, minus what you owe';

  @override
  String get madeUpOf => 'Made up of';

  @override
  String get netWorthHelp =>
      'Switch a part off to leave it out. Total balance starts off: if your income lands in your wallets, it would count the same money twice. Others\' money in your wallets is never counted — it isn\'t yours.';

  @override
  String get trackWallets => 'Track your wallets';

  @override
  String get trackWalletsHelp =>
      'Add JazzCash, Easypaisa, your bank or cash to always know what\'s in each — and how much of it is money you\'re keeping for someone else.';

  @override
  String get addWallet => 'Add a wallet';

  @override
  String get inAllWallets => 'In all wallets';

  @override
  String get moneyYoureKeeping => 'Money you\'re keeping';

  @override
  String get keepingEmptyHelp =>
      'When someone gives you money to keep, add it with Received. It stays in your wallet but isn\'t counted as yours.';

  @override
  String get allReturned => 'All returned';

  @override
  String get yours => 'Yours';

  @override
  String get othersMoney => 'Others\' money';

  @override
  String get received => 'Received';

  @override
  String get sendBack => 'Send back';

  @override
  String get move => 'Move';

  @override
  String othersAmount(String amount) {
    return 'Others\' $amount';
  }

  @override
  String ofAmountInAll(String amount) {
    return 'Of $amount in all';
  }

  @override
  String get allOfItHere => 'All of it is here';

  @override
  String inPlaces(String places) {
    return 'In $places';
  }

  @override
  String get walletOptions => 'Wallet options';

  @override
  String get editWallet => 'Edit wallet';

  @override
  String get correctBalance => 'Correct balance';

  @override
  String get balance => 'Balance';

  @override
  String get othersMoneyInIt => 'Others\' money in it';

  @override
  String get activity => 'Activity';

  @override
  String walletActivityEmpty(String wallet) {
    return 'What you spend, add, receive or send back in $wallet shows up here.';
  }

  @override
  String get editPerson => 'Edit person';

  @override
  String get youreKeeping => 'You\'re keeping';

  @override
  String get history => 'History';

  @override
  String get someone => 'someone';

  @override
  String get aWallet => 'a wallet';

  @override
  String get addedYourMoney => 'Added your money';

  @override
  String receivedFrom(String person) {
    return 'Received from $person';
  }

  @override
  String sentBackTo(String person) {
    return 'Sent back to $person';
  }

  @override
  String movedFrom(String wallet) {
    return 'Moved from $wallet';
  }

  @override
  String movedTo(String wallet) {
    return 'Moved to $wallet';
  }

  @override
  String get balanceCorrected => 'Balance corrected';

  @override
  String get walletNameError => 'Give the wallet a name';

  @override
  String get amountOrEmpty => 'Enter an amount, or leave it empty';

  @override
  String youAlreadyHave(String name) {
    return 'You already have $name';
  }

  @override
  String walletSameNameEdit(String name) {
    return 'Another wallet is called $name. Use the same name for both?';
  }

  @override
  String get walletSameNameAdd => 'Add another wallet with the same name?';

  @override
  String get saveAnyway => 'Save anyway';

  @override
  String get addAnyway => 'Add anyway';

  @override
  String get goBack => 'Go back';

  @override
  String get deleteWalletBody =>
      'Everything recorded in it is deleted too, including money you received in it from others and moves to or from it.';

  @override
  String get newWallet => 'New wallet';

  @override
  String get deleteWallet => 'Delete wallet';

  @override
  String get addWalletButton => 'Add wallet';

  @override
  String get walletNameHint => 'e.g. JazzCash';

  @override
  String get ownMoneyWhenAdded => 'Your own money when added';

  @override
  String get ownMoneyNow => 'Your own money in it now';

  @override
  String get ownMoneyHelp =>
      'Only what\'s yours. Money you\'re keeping for someone is added next with \"Received\", on top of this.';

  @override
  String get deleteCorrectionTitle => 'Delete this correction?';

  @override
  String get deleteCorrectionBody =>
      'The wallet goes back to the balance it showed before you corrected it.';

  @override
  String get pickWhoseMoney => 'Pick whose money it is';

  @override
  String get pickWallet => 'Pick a wallet';

  @override
  String get pickWhereItWent => 'Pick where it went';

  @override
  String get pickDifferentWallet => 'Pick a different wallet';

  @override
  String notKeepingAny(String name) {
    return 'You aren\'t keeping any of $name\'s money';
  }

  @override
  String keepingFor(String amount, String name) {
    return 'You\'re keeping $amount for $name';
  }

  @override
  String get thisWallet => 'This wallet';

  @override
  String moreThanWalletHas(String wallet) {
    return 'More than $wallet has';
  }

  @override
  String moreThanWalletBody(String wallet, String balance, String after) {
    return '$wallet has $balance. Saving this takes it to $after.';
  }

  @override
  String get deleteEntryTitle => 'Delete this entry?';

  @override
  String get deleteEntryBody =>
      'Only for an entry made by mistake. The wallet changes as if it never happened.';

  @override
  String get chooseWallet => 'Choose a wallet';

  @override
  String get editSpending => 'Edit spending';

  @override
  String get spentHelp => 'Money you spent from a wallet.';

  @override
  String get editAddedMoney => 'Edit added money';

  @override
  String get addYourMoney => 'Add your money';

  @override
  String get addYourMoneyHelp => 'Money of your own you put into a wallet.';

  @override
  String get editReceivedMoney => 'Edit received money';

  @override
  String get receivedToKeep => 'Received to keep';

  @override
  String get receivedToKeepHelp =>
      'Money someone gave you to keep. It\'s theirs, not yours, until you send it back.';

  @override
  String get editMoneySentBack => 'Edit money sent back';

  @override
  String get sendBackHelp => 'Money you returned to someone.';

  @override
  String keepingForSentence(String amount, String name) {
    return 'You\'re keeping $amount for $name.';
  }

  @override
  String notKeepingAnySentence(String name) {
    return 'You aren\'t keeping any of $name\'s money.';
  }

  @override
  String get editMove => 'Edit move';

  @override
  String get moveMoney => 'Move money';

  @override
  String get moveMoneyHelp => 'From one of your wallets to another.';

  @override
  String get correction => 'Correction';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get chooseSomeone => 'Choose someone';

  @override
  String get sendBackTo => 'Send back to';

  @override
  String get moveFrom => 'Move from';

  @override
  String get fromWallet => 'From wallet';

  @override
  String get intoWallet => 'Into wallet';

  @override
  String get deleteEntry => 'Delete entry';

  @override
  String get moveTo => 'Move to';

  @override
  String get date => 'Date';

  @override
  String get whatForOptional => 'What for (optional)';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get spentNoteHint => 'e.g. Bike repair';

  @override
  String get receivedNoteHint => 'e.g. Keep it until he asks';

  @override
  String get enterName => 'Enter a name';

  @override
  String alreadyInList(String name) {
    return '$name is already in your list';
  }

  @override
  String get samePersonNameBody =>
      'Two people with the same name are easy to mix up. Use it anyway?';

  @override
  String deletePersonBody(String name) {
    return 'Everything received from and sent back to $name is deleted too, and your wallets change as if none of it happened.';
  }

  @override
  String get deletePerson => 'Delete person';

  @override
  String get enterBalance => 'Enter the balance';

  @override
  String correctWallet(String wallet) {
    return 'Correct $wallet';
  }

  @override
  String correctBalanceHelp(String current, String wallet) {
    return 'The app shows $current. Enter what your $wallet actually has, and the difference is recorded.';
  }

  @override
  String get saveBalance => 'Save balance';

  @override
  String get realBalanceNow => 'Real balance now';

  @override
  String get nextPaymentDue => 'Next payment due';

  @override
  String get giveItName => 'Give it a name';

  @override
  String get enterTotalOwed => 'Enter the total you owe';

  @override
  String moreThanTotal(String total) {
    return 'More than the total of $total';
  }

  @override
  String get enterEachPayment => 'Enter how much you pay each time';

  @override
  String get pickNextDue => 'Pick when the next payment is due';

  @override
  String get sameRepaymentNameBody =>
      'Two repayments with the same name are easy to mix up. Save anyway?';

  @override
  String get deleteRepaymentBody =>
      'Its payment history is deleted. Expenses and wallet entries its payments added are kept.';

  @override
  String get editRepayment => 'Edit repayment';

  @override
  String get newRepayment => 'New repayment';

  @override
  String get newRepaymentHelp =>
      'Money you owe and pay back over time: an installment, a loan, a qisht.';

  @override
  String get deleteRepayment => 'Delete repayment';

  @override
  String get addRepaymentButton => 'Add repayment';

  @override
  String get repaymentNameHint => 'e.g. Bike installment';

  @override
  String get lenderOptional => 'Who it\'s to (optional)';

  @override
  String get lenderHint => 'e.g. Honda dealer';

  @override
  String get totalYouOwe => 'Total you owe';

  @override
  String get alreadyPaidOptional => 'Already paid (optional)';

  @override
  String get alreadyPaidHelp => 'What you paid before adding it here.';

  @override
  String get howOften => 'How often';

  @override
  String everyNMonths(int count) {
    return 'Every $count months';
  }

  @override
  String get fewerMonths => 'Fewer months';

  @override
  String get moreMonths => 'More months';

  @override
  String get eachPayment => 'Each payment';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get noScheduleHelp =>
      'No schedule: pay whatever you can, whenever you can.';

  @override
  String onlyLeftToPay(String amount) {
    return 'Only $amount is left to pay';
  }

  @override
  String get pickExpenseCategory => 'Pick a category for the expense';

  @override
  String payNamed(String name) {
    return 'Pay $name';
  }

  @override
  String leftToPaySentence(String amount) {
    return '$amount left to pay.';
  }

  @override
  String nextDueSentence(String date) {
    return 'Next due $date.';
  }

  @override
  String get savePayment => 'Save payment';

  @override
  String fullPaymentHelp(String amount) {
    return 'A full payment moves the due date to the next one. Less than $amount keeps it.';
  }

  @override
  String get paidFrom => 'Paid from';

  @override
  String get monthlyMoney => 'Monthly money';

  @override
  String get aWalletOption => 'A wallet';

  @override
  String get justRecordIt => 'Just record it';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get addsExpenseHere => 'Adds an expense in this category.';

  @override
  String addsExpenseNotCounted(String category) {
    return 'Adds an expense in $category. Not counted in your monthly budget.';
  }

  @override
  String addsExpenseCounted(String category) {
    return 'Adds an expense in $category. Counts toward your monthly budget.';
  }

  @override
  String get addsSpentEntry =>
      'Adds a \"Spent\" entry in the wallet. Your monthly budget isn\'t touched.';

  @override
  String get onlyUpdatesRepayment =>
      'Only updates this repayment. Nothing is added to your transactions or wallets.';

  @override
  String get deletePaymentTitle => 'Delete this payment?';

  @override
  String paymentGoesBack(String amount) {
    return 'The $amount goes back to what you owe.';
  }

  @override
  String get expenseDeletedToo => 'The expense it added is deleted too.';

  @override
  String spentEntryDeletedToo(String wallet) {
    return 'The \"Spent\" entry it added in $wallet is deleted too.';
  }

  @override
  String get theWallet => 'the wallet';

  @override
  String dueDateGoesBack(String date) {
    return 'The due date goes back to $date.';
  }

  @override
  String scheduleDaily(String amount) {
    return '$amount daily';
  }

  @override
  String scheduleMonthly(String amount) {
    return '$amount monthly';
  }

  @override
  String scheduleEveryMonths(String amount, int count) {
    return '$amount every $count months';
  }

  @override
  String scheduleYearly(String amount) {
    return '$amount yearly';
  }

  @override
  String get trackWhatYouOwe => 'Track what you owe';

  @override
  String get trackWhatYouOweHelp =>
      'Add installments, loans and qisht to see what\'s due next, how much is left, and when you\'ll be done.';

  @override
  String get addRepayment => 'Add a repayment';

  @override
  String get dueThisMonth => 'Due this month';

  @override
  String get active => 'Active';

  @override
  String get everythingPaidOff => 'Everything is paid off.';

  @override
  String installmentsPaidOf(int paid, int count) {
    return '$paid of $count paid';
  }

  @override
  String amountPaidOf(String paid, String total) {
    return '$paid of $total paid';
  }

  @override
  String amountPaid(String amount) {
    return '$amount paid';
  }

  @override
  String amountLeft(String amount) {
    return '$amount left';
  }

  @override
  String get leftToPay => 'Left to pay';

  @override
  String toLender(String lender) {
    return 'to $lender';
  }

  @override
  String get nextDue => 'Next due';

  @override
  String get payments => 'Payments';

  @override
  String get paymentsLeft => 'Payments left';

  @override
  String get doneBy => 'Done by';

  @override
  String get pay => 'Pay';

  @override
  String get paymentsEmpty => 'Payments you make show up here.';

  @override
  String get paidBeforeTracking => 'Paid before tracking';

  @override
  String fromWalletNamed(String wallet) {
    return 'From $wallet';
  }

  @override
  String get recordedOnly => 'Recorded only';

  @override
  String amountOwed(String amount) {
    return '$amount owed';
  }

  @override
  String get reachItBy => 'Reach it by';

  @override
  String get whatSavingFor => 'What are you saving for?';

  @override
  String get enterHowMuchItCosts => 'Enter how much it costs';

  @override
  String get enterAmountOrLeaveEmpty => 'Enter an amount, or leave it empty';

  @override
  String moreThanTarget(String target) {
    return 'More than the target of $target';
  }

  @override
  String get sameGoalNameBody =>
      'Two goals with the same name are easy to mix up. Save anyway?';

  @override
  String get deleteGoalBody =>
      'Its history is deleted. Expenses and wallet entries it added are kept.';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get newGoal => 'New goal';

  @override
  String get newGoalSubtitle =>
      'Something you\'re saving up for: a mobile, a bike, a trip.';

  @override
  String get deleteGoal => 'Delete goal';

  @override
  String get addGoal => 'Add goal';

  @override
  String get savingFor => 'Saving for';

  @override
  String get goalNameHint => 'e.g. New mobile';

  @override
  String get target => 'Target';

  @override
  String get alreadySavedOptional => 'Already saved (optional)';

  @override
  String get reachItByOptional => 'Reach it by (optional)';

  @override
  String get removeDate => 'Remove date';

  @override
  String get goalDateHelp =>
      'With a date, the app works out how much to save each month.';

  @override
  String onlyAmountSaved(String amount) {
    return 'Only $amount is saved';
  }

  @override
  String savedForGoal(String goal) {
    return 'Saved for $goal';
  }

  @override
  String fromGoal(String goal) {
    return 'From $goal';
  }

  @override
  String get fromWhichWallet => 'From which wallet?';

  @override
  String get intoWhichWallet => 'Into which wallet?';

  @override
  String addToGoal(String goal) {
    return 'Add to $goal';
  }

  @override
  String takeOutOfGoal(String goal) {
    return 'Take out of $goal';
  }

  @override
  String savedReachedIt(String saved) {
    return '$saved saved. You\'ve reached it.';
  }

  @override
  String savedToGo(String saved, String remaining) {
    return '$saved saved, $remaining to go.';
  }

  @override
  String savedTakingOutLowers(String saved) {
    return '$saved saved. Taking some out lowers it.';
  }

  @override
  String get takeOut => 'Take out';

  @override
  String get whereItGoes => 'Where it goes';

  @override
  String get addsExpenseGoalHint =>
      'Adds an expense in this category. A \"Savings\" category set to not counted keeps your budget untouched.';

  @override
  String get goalFromWalletHelp =>
      'Takes it out of the wallet and into this goal.';

  @override
  String get goalToWalletHelp =>
      'Puts it back in the wallet as your own money.';

  @override
  String get onlyUpdatesGoal =>
      'Only updates this goal. Nothing is added to your transactions or wallets.';

  @override
  String youReachedGoal(String goal) {
    return 'You reached $goal!';
  }

  @override
  String goalReachedBody(String target) {
    return '$target saved. Bought it? Mark it done and it moves to Done.';
  }

  @override
  String get notYet => 'Not yet';

  @override
  String get markAsDone => 'Mark as done';

  @override
  String get deleteThisSaving => 'Delete this saving?';

  @override
  String get deleteThisTakeOut => 'Delete this take-out?';

  @override
  String goalGoesDownBy(String amount) {
    return 'The goal goes down by $amount.';
  }

  @override
  String goesBackIntoGoal(String amount) {
    return 'The $amount goes back into the goal.';
  }

  @override
  String walletEntryDeletedToo(String wallet) {
    return 'The entry it added in $wallet is deleted too.';
  }

  @override
  String doneOn(String date) {
    return 'Done $date';
  }

  @override
  String get reachedMarkDone => 'Reached — mark it done when you buy it';

  @override
  String saveAMonthToReach(String amount, String date) {
    return 'Save $amount a month to reach it by $date';
  }

  @override
  String amountToGo(String amount) {
    return '$amount to go';
  }

  @override
  String get saveUpForSomething => 'Save up for something';

  @override
  String get saveUpForSomethingHelp =>
      'Add a goal — a new mobile, a bike, a trip — and see how close you are and how much to save each month.';

  @override
  String get addAGoal => 'Add a goal';

  @override
  String get savedForGoals => 'Saved for goals';

  @override
  String get stillToSave => 'Still to save';

  @override
  String get goals => 'Goals';

  @override
  String get allGoalsDone => 'All your goals are done.';

  @override
  String amountOfTotal(String amount, String total) {
    return '$amount of $total';
  }

  @override
  String ofTotal(String total) {
    return 'of $total';
  }

  @override
  String get toGo => 'To go';

  @override
  String get saveEachMonth => 'Save each month';

  @override
  String get notDoneYet => 'Not done yet';

  @override
  String get addMoney => 'Add money';

  @override
  String get goalHistoryEmpty => 'Money you add or take out shows up here.';

  @override
  String get savedBeforeTracking => 'Saved before tracking';

  @override
  String intoWalletNamed(String wallet) {
    return 'Into $wallet';
  }

  @override
  String get added => 'Added';

  @override
  String get tookOut => 'Took out';

  @override
  String amountSaved(String amount) {
    return '$amount saved';
  }

  @override
  String get nameTheAccount => 'Name the account';

  @override
  String get enterWorthNow => 'Enter what it\'s worth now';

  @override
  String get sameAccountNameBody =>
      'Two accounts with the same name are easy to mix up. Save anyway?';

  @override
  String get deleteInvestAccountBody =>
      'Its history is deleted. Expenses, income and wallet entries it added are kept.';

  @override
  String get editAccount => 'Edit account';

  @override
  String get newAccount => 'New account';

  @override
  String get newAccountSubtitle =>
      'A broker account you invest through. Copy the numbers from your broker\'s app.';

  @override
  String get deleteInvestAccount => 'Delete account';

  @override
  String get addAccount => 'Add account';

  @override
  String get accountNameHint => 'e.g. AKD Trade';

  @override
  String get putInSoFar => 'Money you\'ve put in so far';

  @override
  String get putInSoFarHelp =>
      'Everything you deposited, minus anything you took out.';

  @override
  String get worthNowLabel => 'What it\'s worth now';

  @override
  String get worthNowHelp =>
      'Shares plus cash, as your broker\'s app shows it.';

  @override
  String updateNamed(String name) {
    return 'Update $name';
  }

  @override
  String get updateValueSubtitle =>
      'Copy the total value — shares plus cash — from your broker\'s app.';

  @override
  String get saveValue => 'Save value';

  @override
  String get worthNow => 'Worth now';

  @override
  String accountIsWorth(String account, String value) {
    return '$account is worth $value';
  }

  @override
  String investedIn(String account) {
    return 'Invested in $account';
  }

  @override
  String dividendFrom(String account) {
    return 'Dividend from $account';
  }

  @override
  String get putMoneyIn => 'Put money in';

  @override
  String putMoneyInSubtitle(String account) {
    return 'Money you deposited into $account.';
  }

  @override
  String get takeMoneyOut => 'Take money out';

  @override
  String get dividend => 'Dividend';

  @override
  String dividendSubtitle(String account) {
    return 'A dividend from shares in $account.';
  }

  @override
  String get whereItWent => 'Where it went';

  @override
  String get incomeThisMonth => 'Income this month';

  @override
  String get addsIncomeHere => 'Adds income in this category.';

  @override
  String addsIncomeIn(String category) {
    return 'Adds income in $category.';
  }

  @override
  String get takesItOutOfWallet => 'Takes it out of the wallet.';

  @override
  String get addsToWalletAsYours => 'Adds it to the wallet as your own money.';

  @override
  String get onlyUpdatesAccount =>
      'Only updates this account. Nothing is added to your transactions or wallets.';

  @override
  String get deleteThisValue => 'Delete this value?';

  @override
  String get deleteThisDividend => 'Delete this dividend?';

  @override
  String get deleteThisEntry => 'Delete this entry?';

  @override
  String get valueDeleteBody => 'The account goes back to the value before it.';

  @override
  String depositDeleteBody(String amount) {
    return 'The $amount comes off what you put in.';
  }

  @override
  String withdrawDeleteBody(String amount) {
    return 'The $amount goes back into what you put in.';
  }

  @override
  String dividendDeleteBody(String amount) {
    return 'The $amount comes off your gain.';
  }

  @override
  String get transactionDeletedToo =>
      'The transaction it added is deleted too.';

  @override
  String get valueNotUpdatedYet => 'Value not updated yet';

  @override
  String get updatedToday => 'Updated today';

  @override
  String get updatedYesterday => 'Updated yesterday';

  @override
  String updatedDaysAgo(int count) {
    return 'Updated $count days ago';
  }

  @override
  String updatedMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Updated $count months ago',
      one: 'Updated a month ago',
    );
    return '$_temp0';
  }

  @override
  String get trackInvestments => 'Track your investments';

  @override
  String get trackInvestmentsHelp =>
      'Add your PSX accounts with what you\'ve put in and what they\'re worth, and see your gain at a glance.';

  @override
  String get addAnAccount => 'Add an account';

  @override
  String get putIn => 'Put in';

  @override
  String get gain => 'Gain';

  @override
  String includesDividends(String amount) {
    return 'Includes $amount in dividends';
  }

  @override
  String get accounts => 'Accounts';

  @override
  String get copyValueHelp =>
      'Copy each account\'s value from your broker\'s app now and then with Update.';

  @override
  String get update => 'Update';

  @override
  String get valueUpdated => 'Value updated';
}
