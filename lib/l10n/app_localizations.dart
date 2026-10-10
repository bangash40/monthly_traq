import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Language picker: follow the phone's language.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @badgeSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get badgeSoon;

  /// No description provided for @badgePro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get badgePro;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @appLogo.
  ///
  /// In en, this message translates to:
  /// **'MonthlyTraq logo'**
  String get appLogo;

  /// Screen-reader label for a feature that is not built yet.
  ///
  /// In en, this message translates to:
  /// **'{label}, coming soon'**
  String comingSoonLabel(String label);

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Between the email form and the Google button.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @emailSuggestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Did you mean {email}? Tap to use it.'**
  String emailSuggestionLabel(String email);

  /// Text before the suggested email address.
  ///
  /// In en, this message translates to:
  /// **'Did you mean '**
  String get emailSuggestionBefore;

  /// Text after the suggested email address.
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get emailSuggestionAfter;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @backToThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Back to this month'**
  String get backToThisMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Track your income, expenses and monthly budget.'**
  String get aboutTagline;

  /// No description provided for @couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String couldNotSave(String error);

  /// No description provided for @monthStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Month starts on'**
  String get monthStartsOn;

  /// No description provided for @monthStartsOnHelp.
  ///
  /// In en, this message translates to:
  /// **'Pick the day your budget resets — usually your payday.'**
  String get monthStartsOnHelp;

  /// No description provided for @monthStartsOnShortMonths.
  ///
  /// In en, this message translates to:
  /// **'In shorter months, 29–31 fall back to the month\'s last day.'**
  String get monthStartsOnShortMonths;

  /// No description provided for @transactionDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the transaction. Please try again.'**
  String get transactionDeleteFailed;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @transactionRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t bring the transaction back. Please try again.'**
  String get transactionRestoreFailed;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Screen-reader label for the income/spending bar chart.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Income and spending, last month} other{Income and spending, last {count} months}}'**
  String trendChartLabel(int count);

  /// No description provided for @budgetAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount, or 0 for no budget'**
  String get budgetAmountError;

  /// No description provided for @budgetSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save budget: {error}'**
  String budgetSaveFailed(String error);

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// No description provided for @budgetSheetHelp.
  ///
  /// In en, this message translates to:
  /// **'How much you plan to spend each cycle. The meter on Home fills as you go.'**
  String get budgetSheetHelp;

  /// day is an ordinal like "1st" or "25th".
  ///
  /// In en, this message translates to:
  /// **'Resets on the {day}'**
  String budgetResetsOn(String day);

  /// No description provided for @budgetMatchPayday.
  ///
  /// In en, this message translates to:
  /// **'Match it to your payday'**
  String get budgetMatchPayday;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @categoryLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the category limit'**
  String get categoryLimitReached;

  /// No description provided for @categoryNameError.
  ///
  /// In en, this message translates to:
  /// **'Give the category a name'**
  String get categoryNameError;

  /// No description provided for @categorySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save category: {error}'**
  String categorySaveFailed(String error);

  /// No description provided for @categoryAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add category: {error}'**
  String categoryAddFailed(String error);

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @categoryNameHintIncome.
  ///
  /// In en, this message translates to:
  /// **'e.g. Freelance'**
  String get categoryNameHintIncome;

  /// No description provided for @categoryNameHintExpense.
  ///
  /// In en, this message translates to:
  /// **'e.g. Groceries'**
  String get categoryNameHintExpense;

  /// No description provided for @countTowardBudget.
  ///
  /// In en, this message translates to:
  /// **'Count toward monthly budget'**
  String get countTowardBudget;

  /// No description provided for @countTowardBudgetOn.
  ///
  /// In en, this message translates to:
  /// **'Spending here uses up your monthly budget.'**
  String get countTowardBudgetOn;

  /// No description provided for @countTowardBudgetOff.
  ///
  /// In en, this message translates to:
  /// **'Not in budget — for loan repayments, savings and the like. Still lowers your balance.'**
  String get countTowardBudgetOff;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @iconGroupGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get iconGroupGeneral;

  /// No description provided for @iconGroupFood.
  ///
  /// In en, this message translates to:
  /// **'Food & drink'**
  String get iconGroupFood;

  /// No description provided for @iconGroupShopping.
  ///
  /// In en, this message translates to:
  /// **'Groceries & shopping'**
  String get iconGroupShopping;

  /// No description provided for @iconGroupTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get iconGroupTransport;

  /// No description provided for @iconGroupBills.
  ///
  /// In en, this message translates to:
  /// **'Bills & home'**
  String get iconGroupBills;

  /// No description provided for @iconGroupHealth.
  ///
  /// In en, this message translates to:
  /// **'Health & care'**
  String get iconGroupHealth;

  /// No description provided for @iconGroupFamily.
  ///
  /// In en, this message translates to:
  /// **'Family & giving'**
  String get iconGroupFamily;

  /// No description provided for @iconGroupWork.
  ///
  /// In en, this message translates to:
  /// **'Education & work'**
  String get iconGroupWork;

  /// No description provided for @iconGroupFun.
  ///
  /// In en, this message translates to:
  /// **'Fun & travel'**
  String get iconGroupFun;

  /// No description provided for @iconGroupMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get iconGroupMoney;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get tabTransactions;

  /// No description provided for @tabAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get tabAnalytics;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get backOnline;

  /// No description provided for @youreOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get youreOffline;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Changes will sync when you\'re back.'**
  String get offlineMessage;

  /// No description provided for @savedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved on your phone. It\'ll sync when you\'re back online.'**
  String get savedOffline;

  /// No description provided for @onboardingTitleTransactions.
  ///
  /// In en, this message translates to:
  /// **'Every rupee, in one place'**
  String get onboardingTitleTransactions;

  /// No description provided for @onboardingBodyTransactions.
  ///
  /// In en, this message translates to:
  /// **'Log income and expenses in seconds, sorted by category.'**
  String get onboardingBodyTransactions;

  /// No description provided for @onboardingTitleBreakdown.
  ///
  /// In en, this message translates to:
  /// **'See where it goes'**
  String get onboardingTitleBreakdown;

  /// No description provided for @onboardingBodyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'A clear breakdown shows what you spend on, and how much.'**
  String get onboardingBodyBreakdown;

  /// No description provided for @onboardingTitleBudget.
  ///
  /// In en, this message translates to:
  /// **'A budget that keeps up'**
  String get onboardingTitleBudget;

  /// No description provided for @onboardingBodyBudget.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly limit and watch the meter fill as you spend.'**
  String get onboardingBodyBudget;

  /// No description provided for @onboardingTitleTrends.
  ///
  /// In en, this message translates to:
  /// **'Spot your trends'**
  String get onboardingTitleTrends;

  /// No description provided for @onboardingBodyTrends.
  ///
  /// In en, this message translates to:
  /// **'Compare what comes in and goes out, month by month.'**
  String get onboardingBodyTrends;

  /// No description provided for @onboardingTitleSync.
  ///
  /// In en, this message translates to:
  /// **'Safe in your account'**
  String get onboardingTitleSync;

  /// No description provided for @onboardingBodySync.
  ///
  /// In en, this message translates to:
  /// **'Everything syncs to your account, so it\'s there on any device.'**
  String get onboardingBodySync;

  /// No description provided for @authFailedLogIn.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t log you in.'**
  String get authFailedLogIn;

  /// No description provided for @authFailedSignUp.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create your account.'**
  String get authFailedSignUp;

  /// No description provided for @authFailedGoogle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in with Google.'**
  String get authFailedGoogle;

  /// No description provided for @authFailedReset.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the reset email.'**
  String get authFailedReset;

  /// No description provided for @authFailedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t confirm it\'s you.'**
  String get authFailedConfirm;

  /// No description provided for @authFailedDelete.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your account.'**
  String get authFailedDelete;

  /// failed is one of the authFailed… sentences.
  ///
  /// In en, this message translates to:
  /// **'{failed} Please try again.'**
  String authTryAgain(String failed);

  /// No description provided for @authGoogleInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was interrupted. Please try again.'**
  String get authGoogleInterrupted;

  /// No description provided for @authGoogleWrongAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose the Google account you signed up with.'**
  String get authGoogleWrongAccount;

  /// No description provided for @authGoogleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in isn\'t available right now. Use your email instead.'**
  String get authGoogleUnavailable;

  /// No description provided for @authNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get authNoInternet;

  /// No description provided for @authTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a few minutes, then try again.'**
  String get authTooManyAttempts;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address doesn\'t look right.'**
  String get authInvalidEmail;

  /// No description provided for @authMissingEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get authMissingEmail;

  /// No description provided for @authMissingPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get authMissingPassword;

  /// No description provided for @authUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been turned off. Contact {email} for help.'**
  String authUserDisabled(String email);

  /// No description provided for @authEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'That email already has an account. Log in instead.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get authWeakPassword;

  /// No description provided for @authExistsWithPassword.
  ///
  /// In en, this message translates to:
  /// **'That email already has an account. Log in with your email and password.'**
  String get authExistsWithPassword;

  /// No description provided for @authUserMismatch.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t match the account you\'re signed in with.'**
  String get authUserMismatch;

  /// No description provided for @authWrongLogin.
  ///
  /// In en, this message translates to:
  /// **'That email and password don\'t match an account.'**
  String get authWrongLogin;

  /// No description provided for @authWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'That password isn\'t right.'**
  String get authWrongPassword;

  /// No description provided for @authLogInAgain.
  ///
  /// In en, this message translates to:
  /// **'For your security, log out and back in, then try again.'**
  String get authLogInAgain;

  /// No description provided for @authMethodUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This way of signing in isn\'t available right now.'**
  String get authMethodUnavailable;

  /// No description provided for @authBusy.
  ///
  /// In en, this message translates to:
  /// **'We\'re busy right now. Please try again later.'**
  String get authBusy;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address, like name@example.com'**
  String get emailInvalid;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailRequired;

  /// No description provided for @emailHasSpaces.
  ///
  /// In en, this message translates to:
  /// **'An email address can\'t have spaces'**
  String get emailHasSpaces;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Use your real email address — you\'ll need it if you forget your password'**
  String get emailPlaceholder;

  /// No description provided for @emailTemporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary emails can\'t be used — you\'ll need a real one if you forget your password'**
  String get emailTemporary;

  /// No description provided for @passwordSpaceAtEnds.
  ///
  /// In en, this message translates to:
  /// **'A password can\'t start or end with a space'**
  String get passwordSpaceAtEnds;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least {count} characters'**
  String passwordTooShort(int count);

  /// No description provided for @passwordOnlyNumbers.
  ///
  /// In en, this message translates to:
  /// **'Add some letters — numbers alone are easy to guess'**
  String get passwordOnlyNumbers;

  /// No description provided for @passwordTooCommon.
  ///
  /// In en, this message translates to:
  /// **'This password is too common. Try something harder to guess'**
  String get passwordTooCommon;

  /// No description provided for @passwordPersonal.
  ///
  /// In en, this message translates to:
  /// **'Don\'t use your name or email in your password'**
  String get passwordPersonal;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get passwordRequired;

  /// No description provided for @forgotNeedsEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email above, then tap Forgot? again.'**
  String get forgotNeedsEmail;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If {email} has an account, a reset link is on its way.'**
  String resetLinkSent(String email);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to keep tracking your month.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot?'**
  String get forgotPassword;

  /// No description provided for @passwordHintLogin.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get passwordHintLogin;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @passwordEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordEnter;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @newToApp.
  ///
  /// In en, this message translates to:
  /// **'New to MonthlyTraq?'**
  String get newToApp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It takes less than a minute.'**
  String get signupSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameRequired;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordAgain.
  ///
  /// In en, this message translates to:
  /// **'Type your password again'**
  String get passwordAgain;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @passwordStrengthEmpty.
  ///
  /// In en, this message translates to:
  /// **'Use {count} or more characters. A short phrase is easy to remember and hard to guess.'**
  String passwordStrengthEmpty(int count);

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get passwordOkay;

  /// No description provided for @passwordOkayHint.
  ///
  /// In en, this message translates to:
  /// **'Good. A longer password is even stronger.'**
  String get passwordOkayHint;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @passwordStrongHint.
  ///
  /// In en, this message translates to:
  /// **'Great password.'**
  String get passwordStrongHint;

  /// Screen-reader summary of the strength meter; hint may be empty.
  ///
  /// In en, this message translates to:
  /// **'Password strength: {strength}. {hint}'**
  String passwordStrengthLabel(String strength, String hint);

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStep(int step, int total);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @sampleGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get sampleGroceries;

  /// No description provided for @sampleSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get sampleSalary;

  /// No description provided for @sampleBusPass.
  ///
  /// In en, this message translates to:
  /// **'Bus pass'**
  String get sampleBusPass;

  /// After an amount: "Rs. 21,400 left".
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get sampleLeft;

  /// No description provided for @percentUsed.
  ///
  /// In en, this message translates to:
  /// **'{percent}% used'**
  String percentUsed(int percent);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @sampleBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Backed up'**
  String get sampleBackedUp;

  /// No description provided for @sampleJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get sampleJustNow;

  /// No description provided for @sampleFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get sampleFood;

  /// No description provided for @sampleShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get sampleShopping;

  /// No description provided for @sampleEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get sampleEntertainment;

  /// No description provided for @sampleTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get sampleTransport;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and everything in it: your transactions, categories, budget and profile photo. This can\'t be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account…'**
  String get deletingAccount;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeleted;

  /// No description provided for @confirmItsYou.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you'**
  String get confirmItsYou;

  /// No description provided for @confirmPasswordToDelete.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to delete your account.'**
  String get confirmPasswordToDelete;

  /// No description provided for @homeCardBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get homeCardBalance;

  /// No description provided for @homeCardBalanceAbout.
  ///
  /// In en, this message translates to:
  /// **'Your balance, with this month\'s income and spending'**
  String get homeCardBalanceAbout;

  /// No description provided for @homeCardWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get homeCardWallets;

  /// No description provided for @homeCardWalletsAbout.
  ///
  /// In en, this message translates to:
  /// **'What\'s in your wallets, and money you\'re keeping for others. Shows once you add a wallet.'**
  String get homeCardWalletsAbout;

  /// No description provided for @homeCardRepayments.
  ///
  /// In en, this message translates to:
  /// **'Repayments'**
  String get homeCardRepayments;

  /// No description provided for @homeCardRepaymentsAbout.
  ///
  /// In en, this message translates to:
  /// **'What\'s due next on money you owe. Shows once you add a repayment.'**
  String get homeCardRepaymentsAbout;

  /// No description provided for @homeCardGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get homeCardGoals;

  /// No description provided for @homeCardGoalsAbout.
  ///
  /// In en, this message translates to:
  /// **'How close you are to what you\'re saving for. Shows once you add a goal.'**
  String get homeCardGoalsAbout;

  /// No description provided for @homeCardNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Net worth'**
  String get homeCardNetWorth;

  /// No description provided for @homeCardNetWorthAbout.
  ///
  /// In en, this message translates to:
  /// **'What you own minus what you owe: wallets, goals, investments and repayments together.'**
  String get homeCardNetWorthAbout;

  /// No description provided for @homeCardBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get homeCardBudget;

  /// No description provided for @homeCardBudgetAbout.
  ///
  /// In en, this message translates to:
  /// **'How much of your budget is left'**
  String get homeCardBudgetAbout;

  /// No description provided for @homeCardDailyAllowance.
  ///
  /// In en, this message translates to:
  /// **'Daily allowance'**
  String get homeCardDailyAllowance;

  /// No description provided for @homeCardDailyAllowanceAbout.
  ///
  /// In en, this message translates to:
  /// **'How much you can spend today and stay on budget. Needs a monthly budget.'**
  String get homeCardDailyAllowanceAbout;

  /// No description provided for @homeCardTopSpending.
  ///
  /// In en, this message translates to:
  /// **'Top spending'**
  String get homeCardTopSpending;

  /// No description provided for @homeCardTopSpendingAbout.
  ///
  /// In en, this message translates to:
  /// **'Your three biggest categories this month'**
  String get homeCardTopSpendingAbout;

  /// No description provided for @homeCardRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeCardRecent;

  /// No description provided for @homeCardRecentAbout.
  ///
  /// In en, this message translates to:
  /// **'Your latest transactions'**
  String get homeCardRecentAbout;

  /// No description provided for @homeScreenLayout.
  ///
  /// In en, this message translates to:
  /// **'Home screen layout'**
  String get homeScreenLayout;

  /// No description provided for @homeLayoutHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose which cards show on Home, and drag the handle to change their order.'**
  String get homeLayoutHelp;

  /// No description provided for @balanceCardSection.
  ///
  /// In en, this message translates to:
  /// **'Balance card'**
  String get balanceCardSection;

  /// No description provided for @privacyButton.
  ///
  /// In en, this message translates to:
  /// **'Privacy button'**
  String get privacyButton;

  /// No description provided for @privacyButtonAbout.
  ///
  /// In en, this message translates to:
  /// **'Adds an eye button to the balance card that hides your amounts on Home.'**
  String get privacyButtonAbout;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefault;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder {card}'**
  String dragToReorder(String card);

  /// No description provided for @modeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get modeSystem;

  /// No description provided for @modeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get modeLight;

  /// No description provided for @modeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get modeDark;

  /// No description provided for @fontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get fontSizeDefault;

  /// No description provided for @fontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// No description provided for @fontSizeLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get fontSizeLargest;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @textSizePreview.
  ///
  /// In en, this message translates to:
  /// **'Groceries · {amount} — this is how text will look.'**
  String textSizePreview(String amount);

  /// No description provided for @themeCardLabel.
  ///
  /// In en, this message translates to:
  /// **'{name} theme'**
  String themeCardLabel(String name);

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currencySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, code or country'**
  String get currencySearchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noMatchingCurrency.
  ///
  /// In en, this message translates to:
  /// **'No matching currency'**
  String get noMatchingCurrency;

  /// No description provided for @choosePhotoFrame.
  ///
  /// In en, this message translates to:
  /// **'Choose photo frame'**
  String get choosePhotoFrame;

  /// No description provided for @photoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That photo is too large — please choose one under 1MB.'**
  String get photoTooLarge;

  /// No description provided for @photoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update photo: {error}'**
  String photoUpdateFailed(String error);

  /// No description provided for @photoRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove photo: {error}'**
  String photoRemoveFailed(String error);

  /// No description provided for @viewPhoto.
  ///
  /// In en, this message translates to:
  /// **'View photo'**
  String get viewPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @emailCantChange.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in email can\'t be changed here.'**
  String get emailCantChange;

  /// No description provided for @noEmailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app found. Write to {email}'**
  String noEmailApp(String email);

  /// No description provided for @playStoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the Play Store'**
  String get playStoreFailed;

  /// No description provided for @automaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get automaticBackup;

  /// No description provided for @automaticBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you log is saved to your MonthlyTraq account as you go, so it\'s there on any device you sign in on. Changes made offline upload once you\'re back online.'**
  String get automaticBackupBody;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @noTransactionsToDelete.
  ///
  /// In en, this message translates to:
  /// **'There are no transactions to delete'**
  String get noTransactionsToDelete;

  /// No description provided for @deleteAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllDataTitle;

  /// No description provided for @deleteAllDataBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes all {count, plural, =1{1 transaction} other{{count} transactions}} on your account. Your categories and settings are kept. This can\'t be undone.'**
  String deleteAllDataBody(int count);

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @deletedTransactions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Deleted 1 transaction} other{Deleted {count} transactions}}'**
  String deletedTransactions(int count);

  /// No description provided for @couldNotDelete.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String couldNotDelete(String error);

  /// No description provided for @budgetSection.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetSection;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @moneySection.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get moneySection;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Net worth'**
  String get netWorth;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @walletCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 wallet} other{{count} wallets}}'**
  String walletCount(int count);

  /// No description provided for @repayments.
  ///
  /// In en, this message translates to:
  /// **'Repayments'**
  String get repayments;

  /// No description provided for @repaymentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 repayment} other{{count} repayments}}'**
  String repaymentCount(int count);

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get savingsGoals;

  /// No description provided for @goalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 goal} other{{count} goals}}'**
  String goalCount(int count);

  /// No description provided for @investments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investments;

  /// Home screen layout as it comes.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get layoutDefault;

  /// Home screen layout changed by the user.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get layoutCustom;

  /// No description provided for @appIcon.
  ///
  /// In en, this message translates to:
  /// **'App icon'**
  String get appIcon;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticFeedback;

  /// No description provided for @numbersSection.
  ///
  /// In en, this message translates to:
  /// **'Numbers & tools'**
  String get numbersSection;

  /// No description provided for @thousandsSeparator.
  ///
  /// In en, this message translates to:
  /// **'Thousands separator'**
  String get thousandsSeparator;

  /// No description provided for @calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications & sound'**
  String get notificationsSection;

  /// No description provided for @quickAddNotification.
  ///
  /// In en, this message translates to:
  /// **'Quick-add notification'**
  String get quickAddNotification;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @advancedSection.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedSection;

  /// No description provided for @aiSettings.
  ///
  /// In en, this message translates to:
  /// **'AI settings'**
  String get aiSettings;

  /// No description provided for @moreSection.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreSection;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate {app}'**
  String rateApp(String app);

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get backupAutomatic;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @addYourName.
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get addYourName;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @noTransactionsYetHome.
  ///
  /// In en, this message translates to:
  /// **'Log what you spend and earn and it shows up here, grouped by day.'**
  String get noTransactionsYetHome;

  /// No description provided for @addFirstTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction'**
  String get addFirstTransaction;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @showAmounts.
  ///
  /// In en, this message translates to:
  /// **'Show amounts'**
  String get showAmounts;

  /// No description provided for @hideAmounts.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get hideAmounts;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get overBudget;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get setBudget;

  /// No description provided for @setBudgetPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set a budget to see how much is left this month.'**
  String get setBudgetPrompt;

  /// No description provided for @amountOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String amountOver(String amount);

  /// After "Rs. 500 over".
  ///
  /// In en, this message translates to:
  /// **'your {budget} budget'**
  String budgetOverTail(String budget);

  /// After the amount left: "Rs. 14,000 left of Rs. 60,000".
  ///
  /// In en, this message translates to:
  /// **'left of {budget}'**
  String budgetLeftTail(String budget);

  /// No description provided for @budgetUsed.
  ///
  /// In en, this message translates to:
  /// **'Budget used'**
  String get budgetUsed;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String percentValue(int percent);

  /// No description provided for @lastDayOfCycle.
  ///
  /// In en, this message translates to:
  /// **'Last day of this cycle'**
  String get lastDayOfCycle;

  /// No description provided for @daysLeftInCycle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left in cycle} other{{count} days left in cycle}}'**
  String daysLeftInCycle(int count);

  /// After "Rs. 200 over".
  ///
  /// In en, this message translates to:
  /// **'today\'s {amount}'**
  String allowanceOverTail(String amount);

  /// After the amount.
  ///
  /// In en, this message translates to:
  /// **'left to spend today'**
  String get allowanceLeftTail;

  /// No description provided for @allowanceUsedUp.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used this cycle\'s budget. Anything more goes over it.'**
  String get allowanceUsedUp;

  /// No description provided for @allowanceTomorrowLower.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow\'s allowance will be a little lower to stay on budget.'**
  String get allowanceTomorrowLower;

  /// No description provided for @lastDay.
  ///
  /// In en, this message translates to:
  /// **'Last day'**
  String get lastDay;

  /// No description provided for @noBudgetLeft.
  ///
  /// In en, this message translates to:
  /// **'No budget left'**
  String get noBudgetLeft;

  /// No description provided for @allowanceUsed.
  ///
  /// In en, this message translates to:
  /// **'Today\'s allowance used'**
  String get allowanceUsed;

  /// No description provided for @spentToday.
  ///
  /// In en, this message translates to:
  /// **'Spent {amount} today'**
  String spentToday(String amount);

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'{amount} a day'**
  String perDay(String amount);

  /// No description provided for @yoursAndOthers.
  ///
  /// In en, this message translates to:
  /// **'Yours {yours} · Others\' {others}'**
  String yoursAndOthers(String yours, String others);

  /// No description provided for @allYours.
  ///
  /// In en, this message translates to:
  /// **'All yours'**
  String get allYours;

  /// No description provided for @lastCycle.
  ///
  /// In en, this message translates to:
  /// **'Last cycle'**
  String get lastCycle;

  /// No description provided for @underBudget.
  ///
  /// In en, this message translates to:
  /// **'{name} — under budget!'**
  String underBudget(String name);

  /// No description provided for @budgetWinBody.
  ///
  /// In en, this message translates to:
  /// **'You kept {left} of your {budget} budget. Nice work.'**
  String budgetWinBody(String left, String budget);

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @notCountedOne.
  ///
  /// In en, this message translates to:
  /// **'Not counted: {category} · {amount}'**
  String notCountedOne(String category, String amount);

  /// No description provided for @notCountedMany.
  ///
  /// In en, this message translates to:
  /// **'Not counted: {amount} · {count, plural, =1{1 category} other{{count} categories}}'**
  String notCountedMany(String amount, int count);

  /// No description provided for @showDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'{summary}. Show details'**
  String showDetailsLabel(String summary);

  /// No description provided for @notInYourBudget.
  ///
  /// In en, this message translates to:
  /// **'Not in your budget'**
  String get notInYourBudget;

  /// No description provided for @notInBudgetHelp.
  ///
  /// In en, this message translates to:
  /// **'This month\'s spending in these categories lowers your balance and shows in Spent, but doesn\'t use up your monthly budget.'**
  String get notInBudgetHelp;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @notInBudgetHowToChange.
  ///
  /// In en, this message translates to:
  /// **'To change which categories count, go to Profile → Categories → Edit.'**
  String get notInBudgetHowToChange;

  /// No description provided for @deleteNamed.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteNamed(String name);

  /// No description provided for @deleteCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'Transactions in this category are kept and become uncategorized.'**
  String get deleteCategoryBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @couldNotReorder.
  ///
  /// In en, this message translates to:
  /// **'Could not reorder: {error}'**
  String couldNotReorder(String error);

  /// No description provided for @expenseCount.
  ///
  /// In en, this message translates to:
  /// **'Expense · {count}'**
  String expenseCount(int count);

  /// No description provided for @incomeCount.
  ///
  /// In en, this message translates to:
  /// **'Income · {count}'**
  String incomeCount(int count);

  /// No description provided for @categoriesHelp.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. The order here is the order in the add screen.'**
  String get categoriesHelp;

  /// No description provided for @noExpenseCategories.
  ///
  /// In en, this message translates to:
  /// **'No expense categories'**
  String get noExpenseCategories;

  /// No description provided for @noIncomeCategories.
  ///
  /// In en, this message translates to:
  /// **'No income categories'**
  String get noIncomeCategories;

  /// No description provided for @noCategoriesHelp.
  ///
  /// In en, this message translates to:
  /// **'Add one to start sorting what you log.'**
  String get noCategoriesHelp;

  /// No description provided for @notInBudget.
  ///
  /// In en, this message translates to:
  /// **'Not in budget'**
  String get notInBudget;

  /// No description provided for @optionsFor.
  ///
  /// In en, this message translates to:
  /// **'Options for {name}'**
  String optionsFor(String name);

  /// No description provided for @deleteEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Delete…'**
  String get deleteEllipsis;

  /// No description provided for @spending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get spending;

  /// No description provided for @noSpendingIn.
  ///
  /// In en, this message translates to:
  /// **'No spending in {month}'**
  String noSpendingIn(String month);

  /// No description provided for @noIncomeIn.
  ///
  /// In en, this message translates to:
  /// **'No income in {month}'**
  String noIncomeIn(String month);

  /// No description provided for @noSpendingHelp.
  ///
  /// In en, this message translates to:
  /// **'Expenses you log are broken down by category here.'**
  String get noSpendingHelp;

  /// No description provided for @noIncomeHelp.
  ///
  /// In en, this message translates to:
  /// **'Income you log is broken down by category here.'**
  String get noIncomeHelp;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @biggestDay.
  ///
  /// In en, this message translates to:
  /// **'Biggest day'**
  String get biggestDay;

  /// No description provided for @lastSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get lastSixMonths;

  /// Money coming in.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get moneyIn;

  /// Money going out.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get moneyOut;

  /// No description provided for @sameAs.
  ///
  /// In en, this message translates to:
  /// **'Same as {month}'**
  String sameAs(String month);

  /// No description provided for @percentVersus.
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs {month}'**
  String percentVersus(int percent, String month);

  /// No description provided for @shareOfSpending.
  ///
  /// In en, this message translates to:
  /// **'{share}% of spending · {count, plural, =1{1 transaction} other{{count} transactions}}'**
  String shareOfSpending(int share, int count);

  /// No description provided for @shareOfIncome.
  ///
  /// In en, this message translates to:
  /// **'{share}% of income · {count, plural, =1{1 transaction} other{{count} transactions}}'**
  String shareOfIncome(int share, int count);

  /// No description provided for @byDay.
  ///
  /// In en, this message translates to:
  /// **'By day'**
  String get byDay;

  /// No description provided for @nothingIn.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {month}'**
  String nothingIn(String month);

  /// No description provided for @categoryEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'Transactions in this category show up here.'**
  String get categoryEmptyHelp;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get searchTransactions;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @noMatchesHelp.
  ///
  /// In en, this message translates to:
  /// **'Nothing this month matches your search or filter.'**
  String get noMatchesHelp;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @nothingLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged in {month}'**
  String nothingLoggedIn(String month);

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @amountAboveZero.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero'**
  String get amountAboveZero;

  /// No description provided for @pickCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get pickCategory;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addNote;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @saveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save income'**
  String get saveIncome;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get saveExpense;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Tile that adds a new category.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @keyDivide.
  ///
  /// In en, this message translates to:
  /// **'Divide'**
  String get keyDivide;

  /// No description provided for @keyMultiply.
  ///
  /// In en, this message translates to:
  /// **'Multiply'**
  String get keyMultiply;

  /// No description provided for @keyMinus.
  ///
  /// In en, this message translates to:
  /// **'Minus'**
  String get keyMinus;

  /// No description provided for @keyPlus.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get keyPlus;

  /// No description provided for @keyDecimal.
  ///
  /// In en, this message translates to:
  /// **'Decimal point'**
  String get keyDecimal;

  /// No description provided for @keyDeleteDigit.
  ///
  /// In en, this message translates to:
  /// **'Delete digit'**
  String get keyDeleteDigit;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noteHelp.
  ///
  /// In en, this message translates to:
  /// **'Shown as the transaction\'s name. Leave it empty to use the category name.'**
  String get noteHelp;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Groceries at Imtiaz'**
  String get noteHint;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @frequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get frequencyDaily;

  /// No description provided for @frequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequencyMonthly;

  /// No description provided for @frequencyEveryMonths.
  ///
  /// In en, this message translates to:
  /// **'Every few months'**
  String get frequencyEveryMonths;

  /// No description provided for @frequencyYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get frequencyYearly;

  /// No description provided for @frequencyNone.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get frequencyNone;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get dueTomorrow;

  /// No description provided for @overdueDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Overdue 1 day} other{Overdue {count} days}}'**
  String overdueDays(int count);

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Due in 1 day} other{Due in {count} days}}'**
  String dueInDays(int count);

  /// No description provided for @paidOff.
  ///
  /// In en, this message translates to:
  /// **'Paid off'**
  String get paidOff;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get goalReached;

  /// No description provided for @goalOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get goalOnTrack;

  /// No description provided for @goalBehind.
  ///
  /// In en, this message translates to:
  /// **'Behind'**
  String get goalBehind;

  /// No description provided for @goalDatePassed.
  ///
  /// In en, this message translates to:
  /// **'Date passed'**
  String get goalDatePassed;

  /// No description provided for @goalNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get goalNoDate;

  /// A savings goal marked as bought.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get goalDone;

  /// No description provided for @stillOwed.
  ///
  /// In en, this message translates to:
  /// **'Still owed'**
  String get stillOwed;

  /// No description provided for @netWorthWalletsAbout.
  ///
  /// In en, this message translates to:
  /// **'Your own money in them, not others\''**
  String get netWorthWalletsAbout;

  /// No description provided for @netWorthGoalsAbout.
  ///
  /// In en, this message translates to:
  /// **'Money moved into goals from monthly money or a wallet'**
  String get netWorthGoalsAbout;

  /// No description provided for @netWorthInvestmentsAbout.
  ///
  /// In en, this message translates to:
  /// **'What your accounts are worth now'**
  String get netWorthInvestmentsAbout;

  /// No description provided for @netWorthBalanceAbout.
  ///
  /// In en, this message translates to:
  /// **'Income minus spending, from Home'**
  String get netWorthBalanceAbout;

  /// No description provided for @netWorthOwedAbout.
  ///
  /// In en, this message translates to:
  /// **'What\'s left to pay on repayments'**
  String get netWorthOwedAbout;

  /// No description provided for @noInternetTryAgain.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Try again when you\'re back online.'**
  String get noInternetTryAgain;

  /// No description provided for @couldntSaveTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Please try again.'**
  String get couldntSaveTryAgain;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesBody.
  ///
  /// In en, this message translates to:
  /// **'What you typed here won\'t be saved.'**
  String get discardChangesBody;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @whichWallet.
  ///
  /// In en, this message translates to:
  /// **'Which wallet?'**
  String get whichWallet;

  /// No description provided for @noWallet.
  ///
  /// In en, this message translates to:
  /// **'No wallet'**
  String get noWallet;

  /// No description provided for @whoseMoney.
  ///
  /// In en, this message translates to:
  /// **'Whose money?'**
  String get whoseMoney;

  /// No description provided for @someoneNewHint.
  ///
  /// In en, this message translates to:
  /// **'Someone new, e.g. Ahmed'**
  String get someoneNewHint;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @notCounted.
  ///
  /// In en, this message translates to:
  /// **'Not counted'**
  String get notCounted;

  /// No description provided for @netWorthTagline.
  ///
  /// In en, this message translates to:
  /// **'What you own, minus what you owe'**
  String get netWorthTagline;

  /// No description provided for @madeUpOf.
  ///
  /// In en, this message translates to:
  /// **'Made up of'**
  String get madeUpOf;

  /// No description provided for @netWorthHelp.
  ///
  /// In en, this message translates to:
  /// **'Switch a part off to leave it out. Total balance starts off: if your income lands in your wallets, it would count the same money twice. Others\' money in your wallets is never counted — it isn\'t yours.'**
  String get netWorthHelp;

  /// No description provided for @trackWallets.
  ///
  /// In en, this message translates to:
  /// **'Track your wallets'**
  String get trackWallets;

  /// No description provided for @trackWalletsHelp.
  ///
  /// In en, this message translates to:
  /// **'Add JazzCash, Easypaisa, your bank or cash to always know what\'s in each — and how much of it is money you\'re keeping for someone else.'**
  String get trackWalletsHelp;

  /// No description provided for @addWallet.
  ///
  /// In en, this message translates to:
  /// **'Add a wallet'**
  String get addWallet;

  /// No description provided for @inAllWallets.
  ///
  /// In en, this message translates to:
  /// **'In all wallets'**
  String get inAllWallets;

  /// No description provided for @moneyYoureKeeping.
  ///
  /// In en, this message translates to:
  /// **'Money you\'re keeping'**
  String get moneyYoureKeeping;

  /// No description provided for @keepingEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'When someone gives you money to keep, add it with Received. It stays in your wallet but isn\'t counted as yours.'**
  String get keepingEmptyHelp;

  /// No description provided for @allReturned.
  ///
  /// In en, this message translates to:
  /// **'All returned'**
  String get allReturned;

  /// No description provided for @yours.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get yours;

  /// No description provided for @othersMoney.
  ///
  /// In en, this message translates to:
  /// **'Others\' money'**
  String get othersMoney;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @sendBack.
  ///
  /// In en, this message translates to:
  /// **'Send back'**
  String get sendBack;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @othersAmount.
  ///
  /// In en, this message translates to:
  /// **'Others\' {amount}'**
  String othersAmount(String amount);

  /// No description provided for @ofAmountInAll.
  ///
  /// In en, this message translates to:
  /// **'Of {amount} in all'**
  String ofAmountInAll(String amount);

  /// No description provided for @allOfItHere.
  ///
  /// In en, this message translates to:
  /// **'All of it is here'**
  String get allOfItHere;

  /// Which wallets, e.g. "In JazzCash, Easypaisa".
  ///
  /// In en, this message translates to:
  /// **'In {places}'**
  String inPlaces(String places);

  /// No description provided for @walletOptions.
  ///
  /// In en, this message translates to:
  /// **'Wallet options'**
  String get walletOptions;

  /// No description provided for @editWallet.
  ///
  /// In en, this message translates to:
  /// **'Edit wallet'**
  String get editWallet;

  /// No description provided for @correctBalance.
  ///
  /// In en, this message translates to:
  /// **'Correct balance'**
  String get correctBalance;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @othersMoneyInIt.
  ///
  /// In en, this message translates to:
  /// **'Others\' money in it'**
  String get othersMoneyInIt;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @walletActivityEmpty.
  ///
  /// In en, this message translates to:
  /// **'What you spend, add, receive or send back in {wallet} shows up here.'**
  String walletActivityEmpty(String wallet);

  /// No description provided for @editPerson.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get editPerson;

  /// No description provided for @youreKeeping.
  ///
  /// In en, this message translates to:
  /// **'You\'re keeping'**
  String get youreKeeping;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @someone.
  ///
  /// In en, this message translates to:
  /// **'someone'**
  String get someone;

  /// No description provided for @aWallet.
  ///
  /// In en, this message translates to:
  /// **'a wallet'**
  String get aWallet;

  /// No description provided for @addedYourMoney.
  ///
  /// In en, this message translates to:
  /// **'Added your money'**
  String get addedYourMoney;

  /// No description provided for @receivedFrom.
  ///
  /// In en, this message translates to:
  /// **'Received from {person}'**
  String receivedFrom(String person);

  /// No description provided for @sentBackTo.
  ///
  /// In en, this message translates to:
  /// **'Sent back to {person}'**
  String sentBackTo(String person);

  /// No description provided for @movedFrom.
  ///
  /// In en, this message translates to:
  /// **'Moved from {wallet}'**
  String movedFrom(String wallet);

  /// No description provided for @movedTo.
  ///
  /// In en, this message translates to:
  /// **'Moved to {wallet}'**
  String movedTo(String wallet);

  /// No description provided for @balanceCorrected.
  ///
  /// In en, this message translates to:
  /// **'Balance corrected'**
  String get balanceCorrected;

  /// No description provided for @walletNameError.
  ///
  /// In en, this message translates to:
  /// **'Give the wallet a name'**
  String get walletNameError;

  /// No description provided for @amountOrEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount, or leave it empty'**
  String get amountOrEmpty;

  /// No description provided for @youAlreadyHave.
  ///
  /// In en, this message translates to:
  /// **'You already have {name}'**
  String youAlreadyHave(String name);

  /// No description provided for @walletSameNameEdit.
  ///
  /// In en, this message translates to:
  /// **'Another wallet is called {name}. Use the same name for both?'**
  String walletSameNameEdit(String name);

  /// No description provided for @walletSameNameAdd.
  ///
  /// In en, this message translates to:
  /// **'Add another wallet with the same name?'**
  String get walletSameNameAdd;

  /// No description provided for @saveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get saveAnyway;

  /// No description provided for @addAnyway.
  ///
  /// In en, this message translates to:
  /// **'Add anyway'**
  String get addAnyway;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @deleteWalletBody.
  ///
  /// In en, this message translates to:
  /// **'Everything recorded in it is deleted too, including money you received in it from others and moves to or from it.'**
  String get deleteWalletBody;

  /// No description provided for @newWallet.
  ///
  /// In en, this message translates to:
  /// **'New wallet'**
  String get newWallet;

  /// No description provided for @deleteWallet.
  ///
  /// In en, this message translates to:
  /// **'Delete wallet'**
  String get deleteWallet;

  /// No description provided for @addWalletButton.
  ///
  /// In en, this message translates to:
  /// **'Add wallet'**
  String get addWalletButton;

  /// No description provided for @walletNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. JazzCash'**
  String get walletNameHint;

  /// No description provided for @ownMoneyWhenAdded.
  ///
  /// In en, this message translates to:
  /// **'Your own money when added'**
  String get ownMoneyWhenAdded;

  /// No description provided for @ownMoneyNow.
  ///
  /// In en, this message translates to:
  /// **'Your own money in it now'**
  String get ownMoneyNow;

  /// No description provided for @ownMoneyHelp.
  ///
  /// In en, this message translates to:
  /// **'Only what\'s yours. Money you\'re keeping for someone is added next with \"Received\", on top of this.'**
  String get ownMoneyHelp;

  /// No description provided for @deleteCorrectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this correction?'**
  String get deleteCorrectionTitle;

  /// No description provided for @deleteCorrectionBody.
  ///
  /// In en, this message translates to:
  /// **'The wallet goes back to the balance it showed before you corrected it.'**
  String get deleteCorrectionBody;

  /// No description provided for @pickWhoseMoney.
  ///
  /// In en, this message translates to:
  /// **'Pick whose money it is'**
  String get pickWhoseMoney;

  /// No description provided for @pickWallet.
  ///
  /// In en, this message translates to:
  /// **'Pick a wallet'**
  String get pickWallet;

  /// No description provided for @pickWhereItWent.
  ///
  /// In en, this message translates to:
  /// **'Pick where it went'**
  String get pickWhereItWent;

  /// No description provided for @pickDifferentWallet.
  ///
  /// In en, this message translates to:
  /// **'Pick a different wallet'**
  String get pickDifferentWallet;

  /// No description provided for @notKeepingAny.
  ///
  /// In en, this message translates to:
  /// **'You aren\'t keeping any of {name}\'s money'**
  String notKeepingAny(String name);

  /// No description provided for @keepingFor.
  ///
  /// In en, this message translates to:
  /// **'You\'re keeping {amount} for {name}'**
  String keepingFor(String amount, String name);

  /// No description provided for @thisWallet.
  ///
  /// In en, this message translates to:
  /// **'This wallet'**
  String get thisWallet;

  /// No description provided for @moreThanWalletHas.
  ///
  /// In en, this message translates to:
  /// **'More than {wallet} has'**
  String moreThanWalletHas(String wallet);

  /// No description provided for @moreThanWalletBody.
  ///
  /// In en, this message translates to:
  /// **'{wallet} has {balance}. Saving this takes it to {after}.'**
  String moreThanWalletBody(String wallet, String balance, String after);

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteEntryTitle;

  /// No description provided for @deleteEntryBody.
  ///
  /// In en, this message translates to:
  /// **'Only for an entry made by mistake. The wallet changes as if it never happened.'**
  String get deleteEntryBody;

  /// No description provided for @chooseWallet.
  ///
  /// In en, this message translates to:
  /// **'Choose a wallet'**
  String get chooseWallet;

  /// No description provided for @editSpending.
  ///
  /// In en, this message translates to:
  /// **'Edit spending'**
  String get editSpending;

  /// No description provided for @spentHelp.
  ///
  /// In en, this message translates to:
  /// **'Money you spent from a wallet.'**
  String get spentHelp;

  /// No description provided for @editAddedMoney.
  ///
  /// In en, this message translates to:
  /// **'Edit added money'**
  String get editAddedMoney;

  /// No description provided for @addYourMoney.
  ///
  /// In en, this message translates to:
  /// **'Add your money'**
  String get addYourMoney;

  /// No description provided for @addYourMoneyHelp.
  ///
  /// In en, this message translates to:
  /// **'Money of your own you put into a wallet.'**
  String get addYourMoneyHelp;

  /// No description provided for @editReceivedMoney.
  ///
  /// In en, this message translates to:
  /// **'Edit received money'**
  String get editReceivedMoney;

  /// No description provided for @receivedToKeep.
  ///
  /// In en, this message translates to:
  /// **'Received to keep'**
  String get receivedToKeep;

  /// No description provided for @receivedToKeepHelp.
  ///
  /// In en, this message translates to:
  /// **'Money someone gave you to keep. It\'s theirs, not yours, until you send it back.'**
  String get receivedToKeepHelp;

  /// No description provided for @editMoneySentBack.
  ///
  /// In en, this message translates to:
  /// **'Edit money sent back'**
  String get editMoneySentBack;

  /// No description provided for @sendBackHelp.
  ///
  /// In en, this message translates to:
  /// **'Money you returned to someone.'**
  String get sendBackHelp;

  /// No description provided for @keepingForSentence.
  ///
  /// In en, this message translates to:
  /// **'You\'re keeping {amount} for {name}.'**
  String keepingForSentence(String amount, String name);

  /// No description provided for @notKeepingAnySentence.
  ///
  /// In en, this message translates to:
  /// **'You aren\'t keeping any of {name}\'s money.'**
  String notKeepingAnySentence(String name);

  /// No description provided for @editMove.
  ///
  /// In en, this message translates to:
  /// **'Edit move'**
  String get editMove;

  /// No description provided for @moveMoney.
  ///
  /// In en, this message translates to:
  /// **'Move money'**
  String get moveMoney;

  /// No description provided for @moveMoneyHelp.
  ///
  /// In en, this message translates to:
  /// **'From one of your wallets to another.'**
  String get moveMoneyHelp;

  /// No description provided for @correction.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get correction;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @chooseSomeone.
  ///
  /// In en, this message translates to:
  /// **'Choose someone'**
  String get chooseSomeone;

  /// No description provided for @sendBackTo.
  ///
  /// In en, this message translates to:
  /// **'Send back to'**
  String get sendBackTo;

  /// No description provided for @moveFrom.
  ///
  /// In en, this message translates to:
  /// **'Move from'**
  String get moveFrom;

  /// No description provided for @fromWallet.
  ///
  /// In en, this message translates to:
  /// **'From wallet'**
  String get fromWallet;

  /// No description provided for @intoWallet.
  ///
  /// In en, this message translates to:
  /// **'Into wallet'**
  String get intoWallet;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get deleteEntry;

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get moveTo;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @whatForOptional.
  ///
  /// In en, this message translates to:
  /// **'What for (optional)'**
  String get whatForOptional;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @spentNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bike repair'**
  String get spentNoteHint;

  /// No description provided for @receivedNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Keep it until he asks'**
  String get receivedNoteHint;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterName;

  /// No description provided for @alreadyInList.
  ///
  /// In en, this message translates to:
  /// **'{name} is already in your list'**
  String alreadyInList(String name);

  /// No description provided for @samePersonNameBody.
  ///
  /// In en, this message translates to:
  /// **'Two people with the same name are easy to mix up. Use it anyway?'**
  String get samePersonNameBody;

  /// No description provided for @deletePersonBody.
  ///
  /// In en, this message translates to:
  /// **'Everything received from and sent back to {name} is deleted too, and your wallets change as if none of it happened.'**
  String deletePersonBody(String name);

  /// No description provided for @deletePerson.
  ///
  /// In en, this message translates to:
  /// **'Delete person'**
  String get deletePerson;

  /// No description provided for @enterBalance.
  ///
  /// In en, this message translates to:
  /// **'Enter the balance'**
  String get enterBalance;

  /// No description provided for @correctWallet.
  ///
  /// In en, this message translates to:
  /// **'Correct {wallet}'**
  String correctWallet(String wallet);

  /// No description provided for @correctBalanceHelp.
  ///
  /// In en, this message translates to:
  /// **'The app shows {current}. Enter what your {wallet} actually has, and the difference is recorded.'**
  String correctBalanceHelp(String current, String wallet);

  /// No description provided for @saveBalance.
  ///
  /// In en, this message translates to:
  /// **'Save balance'**
  String get saveBalance;

  /// No description provided for @realBalanceNow.
  ///
  /// In en, this message translates to:
  /// **'Real balance now'**
  String get realBalanceNow;

  /// No description provided for @nextPaymentDue.
  ///
  /// In en, this message translates to:
  /// **'Next payment due'**
  String get nextPaymentDue;

  /// No description provided for @giveItName.
  ///
  /// In en, this message translates to:
  /// **'Give it a name'**
  String get giveItName;

  /// No description provided for @enterTotalOwed.
  ///
  /// In en, this message translates to:
  /// **'Enter the total you owe'**
  String get enterTotalOwed;

  /// No description provided for @moreThanTotal.
  ///
  /// In en, this message translates to:
  /// **'More than the total of {total}'**
  String moreThanTotal(String total);

  /// No description provided for @enterEachPayment.
  ///
  /// In en, this message translates to:
  /// **'Enter how much you pay each time'**
  String get enterEachPayment;

  /// No description provided for @pickNextDue.
  ///
  /// In en, this message translates to:
  /// **'Pick when the next payment is due'**
  String get pickNextDue;

  /// No description provided for @sameRepaymentNameBody.
  ///
  /// In en, this message translates to:
  /// **'Two repayments with the same name are easy to mix up. Save anyway?'**
  String get sameRepaymentNameBody;

  /// No description provided for @deleteRepaymentBody.
  ///
  /// In en, this message translates to:
  /// **'Its payment history is deleted. Expenses and wallet entries its payments added are kept.'**
  String get deleteRepaymentBody;

  /// No description provided for @editRepayment.
  ///
  /// In en, this message translates to:
  /// **'Edit repayment'**
  String get editRepayment;

  /// No description provided for @newRepayment.
  ///
  /// In en, this message translates to:
  /// **'New repayment'**
  String get newRepayment;

  /// No description provided for @newRepaymentHelp.
  ///
  /// In en, this message translates to:
  /// **'Money you owe and pay back over time: an installment, a loan, a qisht.'**
  String get newRepaymentHelp;

  /// No description provided for @deleteRepayment.
  ///
  /// In en, this message translates to:
  /// **'Delete repayment'**
  String get deleteRepayment;

  /// No description provided for @addRepaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Add repayment'**
  String get addRepaymentButton;

  /// No description provided for @repaymentNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bike installment'**
  String get repaymentNameHint;

  /// No description provided for @lenderOptional.
  ///
  /// In en, this message translates to:
  /// **'Who it\'s to (optional)'**
  String get lenderOptional;

  /// No description provided for @lenderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Honda dealer'**
  String get lenderHint;

  /// No description provided for @totalYouOwe.
  ///
  /// In en, this message translates to:
  /// **'Total you owe'**
  String get totalYouOwe;

  /// No description provided for @alreadyPaidOptional.
  ///
  /// In en, this message translates to:
  /// **'Already paid (optional)'**
  String get alreadyPaidOptional;

  /// No description provided for @alreadyPaidHelp.
  ///
  /// In en, this message translates to:
  /// **'What you paid before adding it here.'**
  String get alreadyPaidHelp;

  /// No description provided for @howOften.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get howOften;

  /// No description provided for @everyNMonths.
  ///
  /// In en, this message translates to:
  /// **'Every {count} months'**
  String everyNMonths(int count);

  /// No description provided for @fewerMonths.
  ///
  /// In en, this message translates to:
  /// **'Fewer months'**
  String get fewerMonths;

  /// No description provided for @moreMonths.
  ///
  /// In en, this message translates to:
  /// **'More months'**
  String get moreMonths;

  /// No description provided for @eachPayment.
  ///
  /// In en, this message translates to:
  /// **'Each payment'**
  String get eachPayment;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @noScheduleHelp.
  ///
  /// In en, this message translates to:
  /// **'No schedule: pay whatever you can, whenever you can.'**
  String get noScheduleHelp;

  /// No description provided for @onlyLeftToPay.
  ///
  /// In en, this message translates to:
  /// **'Only {amount} is left to pay'**
  String onlyLeftToPay(String amount);

  /// No description provided for @pickExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a category for the expense'**
  String get pickExpenseCategory;

  /// No description provided for @payNamed.
  ///
  /// In en, this message translates to:
  /// **'Pay {name}'**
  String payNamed(String name);

  /// No description provided for @leftToPaySentence.
  ///
  /// In en, this message translates to:
  /// **'{amount} left to pay.'**
  String leftToPaySentence(String amount);

  /// No description provided for @nextDueSentence.
  ///
  /// In en, this message translates to:
  /// **'Next due {date}.'**
  String nextDueSentence(String date);

  /// No description provided for @savePayment.
  ///
  /// In en, this message translates to:
  /// **'Save payment'**
  String get savePayment;

  /// No description provided for @fullPaymentHelp.
  ///
  /// In en, this message translates to:
  /// **'A full payment moves the due date to the next one. Less than {amount} keeps it.'**
  String fullPaymentHelp(String amount);

  /// No description provided for @paidFrom.
  ///
  /// In en, this message translates to:
  /// **'Paid from'**
  String get paidFrom;

  /// No description provided for @monthlyMoney.
  ///
  /// In en, this message translates to:
  /// **'Monthly money'**
  String get monthlyMoney;

  /// No description provided for @aWalletOption.
  ///
  /// In en, this message translates to:
  /// **'A wallet'**
  String get aWalletOption;

  /// No description provided for @justRecordIt.
  ///
  /// In en, this message translates to:
  /// **'Just record it'**
  String get justRecordIt;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @addsExpenseHere.
  ///
  /// In en, this message translates to:
  /// **'Adds an expense in this category.'**
  String get addsExpenseHere;

  /// No description provided for @addsExpenseNotCounted.
  ///
  /// In en, this message translates to:
  /// **'Adds an expense in {category}. Not counted in your monthly budget.'**
  String addsExpenseNotCounted(String category);

  /// No description provided for @addsExpenseCounted.
  ///
  /// In en, this message translates to:
  /// **'Adds an expense in {category}. Counts toward your monthly budget.'**
  String addsExpenseCounted(String category);

  /// No description provided for @addsSpentEntry.
  ///
  /// In en, this message translates to:
  /// **'Adds a \"Spent\" entry in the wallet. Your monthly budget isn\'t touched.'**
  String get addsSpentEntry;

  /// No description provided for @onlyUpdatesRepayment.
  ///
  /// In en, this message translates to:
  /// **'Only updates this repayment. Nothing is added to your transactions or wallets.'**
  String get onlyUpdatesRepayment;

  /// No description provided for @deletePaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this payment?'**
  String get deletePaymentTitle;

  /// No description provided for @paymentGoesBack.
  ///
  /// In en, this message translates to:
  /// **'The {amount} goes back to what you owe.'**
  String paymentGoesBack(String amount);

  /// No description provided for @expenseDeletedToo.
  ///
  /// In en, this message translates to:
  /// **'The expense it added is deleted too.'**
  String get expenseDeletedToo;

  /// No description provided for @spentEntryDeletedToo.
  ///
  /// In en, this message translates to:
  /// **'The \"Spent\" entry it added in {wallet} is deleted too.'**
  String spentEntryDeletedToo(String wallet);

  /// No description provided for @theWallet.
  ///
  /// In en, this message translates to:
  /// **'the wallet'**
  String get theWallet;

  /// No description provided for @dueDateGoesBack.
  ///
  /// In en, this message translates to:
  /// **'The due date goes back to {date}.'**
  String dueDateGoesBack(String date);

  /// No description provided for @scheduleDaily.
  ///
  /// In en, this message translates to:
  /// **'{amount} daily'**
  String scheduleDaily(String amount);

  /// No description provided for @scheduleMonthly.
  ///
  /// In en, this message translates to:
  /// **'{amount} monthly'**
  String scheduleMonthly(String amount);

  /// No description provided for @scheduleEveryMonths.
  ///
  /// In en, this message translates to:
  /// **'{amount} every {count} months'**
  String scheduleEveryMonths(String amount, int count);

  /// No description provided for @scheduleYearly.
  ///
  /// In en, this message translates to:
  /// **'{amount} yearly'**
  String scheduleYearly(String amount);

  /// No description provided for @trackWhatYouOwe.
  ///
  /// In en, this message translates to:
  /// **'Track what you owe'**
  String get trackWhatYouOwe;

  /// No description provided for @trackWhatYouOweHelp.
  ///
  /// In en, this message translates to:
  /// **'Add installments, loans and qisht to see what\'s due next, how much is left, and when you\'ll be done.'**
  String get trackWhatYouOweHelp;

  /// No description provided for @addRepayment.
  ///
  /// In en, this message translates to:
  /// **'Add a repayment'**
  String get addRepayment;

  /// No description provided for @dueThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Due this month'**
  String get dueThisMonth;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @everythingPaidOff.
  ///
  /// In en, this message translates to:
  /// **'Everything is paid off.'**
  String get everythingPaidOff;

  /// No description provided for @installmentsPaidOf.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {count} paid'**
  String installmentsPaidOf(int paid, int count);

  /// No description provided for @amountPaidOf.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {total} paid'**
  String amountPaidOf(String paid, String total);

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'{amount} paid'**
  String amountPaid(String amount);

  /// No description provided for @amountLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String amountLeft(String amount);

  /// No description provided for @leftToPay.
  ///
  /// In en, this message translates to:
  /// **'Left to pay'**
  String get leftToPay;

  /// No description provided for @toLender.
  ///
  /// In en, this message translates to:
  /// **'to {lender}'**
  String toLender(String lender);

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get nextDue;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @paymentsLeft.
  ///
  /// In en, this message translates to:
  /// **'Payments left'**
  String get paymentsLeft;

  /// No description provided for @doneBy.
  ///
  /// In en, this message translates to:
  /// **'Done by'**
  String get doneBy;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @paymentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Payments you make show up here.'**
  String get paymentsEmpty;

  /// No description provided for @paidBeforeTracking.
  ///
  /// In en, this message translates to:
  /// **'Paid before tracking'**
  String get paidBeforeTracking;

  /// No description provided for @fromWalletNamed.
  ///
  /// In en, this message translates to:
  /// **'From {wallet}'**
  String fromWalletNamed(String wallet);

  /// No description provided for @recordedOnly.
  ///
  /// In en, this message translates to:
  /// **'Recorded only'**
  String get recordedOnly;

  /// No description provided for @amountOwed.
  ///
  /// In en, this message translates to:
  /// **'{amount} owed'**
  String amountOwed(String amount);

  /// No description provided for @reachItBy.
  ///
  /// In en, this message translates to:
  /// **'Reach it by'**
  String get reachItBy;

  /// No description provided for @whatSavingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you saving for?'**
  String get whatSavingFor;

  /// No description provided for @enterHowMuchItCosts.
  ///
  /// In en, this message translates to:
  /// **'Enter how much it costs'**
  String get enterHowMuchItCosts;

  /// No description provided for @enterAmountOrLeaveEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount, or leave it empty'**
  String get enterAmountOrLeaveEmpty;

  /// No description provided for @moreThanTarget.
  ///
  /// In en, this message translates to:
  /// **'More than the target of {target}'**
  String moreThanTarget(String target);

  /// No description provided for @sameGoalNameBody.
  ///
  /// In en, this message translates to:
  /// **'Two goals with the same name are easy to mix up. Save anyway?'**
  String get sameGoalNameBody;

  /// No description provided for @deleteGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Its history is deleted. Expenses and wallet entries it added are kept.'**
  String get deleteGoalBody;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get editGoal;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get newGoal;

  /// No description provided for @newGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Something you\'re saving up for: a mobile, a bike, a trip.'**
  String get newGoalSubtitle;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get deleteGoal;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get addGoal;

  /// No description provided for @savingFor.
  ///
  /// In en, this message translates to:
  /// **'Saving for'**
  String get savingFor;

  /// No description provided for @goalNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. New mobile'**
  String get goalNameHint;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @alreadySavedOptional.
  ///
  /// In en, this message translates to:
  /// **'Already saved (optional)'**
  String get alreadySavedOptional;

  /// No description provided for @reachItByOptional.
  ///
  /// In en, this message translates to:
  /// **'Reach it by (optional)'**
  String get reachItByOptional;

  /// No description provided for @removeDate.
  ///
  /// In en, this message translates to:
  /// **'Remove date'**
  String get removeDate;

  /// No description provided for @goalDateHelp.
  ///
  /// In en, this message translates to:
  /// **'With a date, the app works out how much to save each month.'**
  String get goalDateHelp;

  /// No description provided for @onlyAmountSaved.
  ///
  /// In en, this message translates to:
  /// **'Only {amount} is saved'**
  String onlyAmountSaved(String amount);

  /// No description provided for @savedForGoal.
  ///
  /// In en, this message translates to:
  /// **'Saved for {goal}'**
  String savedForGoal(String goal);

  /// No description provided for @fromGoal.
  ///
  /// In en, this message translates to:
  /// **'From {goal}'**
  String fromGoal(String goal);

  /// No description provided for @fromWhichWallet.
  ///
  /// In en, this message translates to:
  /// **'From which wallet?'**
  String get fromWhichWallet;

  /// No description provided for @intoWhichWallet.
  ///
  /// In en, this message translates to:
  /// **'Into which wallet?'**
  String get intoWhichWallet;

  /// No description provided for @addToGoal.
  ///
  /// In en, this message translates to:
  /// **'Add to {goal}'**
  String addToGoal(String goal);

  /// No description provided for @takeOutOfGoal.
  ///
  /// In en, this message translates to:
  /// **'Take out of {goal}'**
  String takeOutOfGoal(String goal);

  /// No description provided for @savedReachedIt.
  ///
  /// In en, this message translates to:
  /// **'{saved} saved. You\'ve reached it.'**
  String savedReachedIt(String saved);

  /// No description provided for @savedToGo.
  ///
  /// In en, this message translates to:
  /// **'{saved} saved, {remaining} to go.'**
  String savedToGo(String saved, String remaining);

  /// No description provided for @savedTakingOutLowers.
  ///
  /// In en, this message translates to:
  /// **'{saved} saved. Taking some out lowers it.'**
  String savedTakingOutLowers(String saved);

  /// No description provided for @takeOut.
  ///
  /// In en, this message translates to:
  /// **'Take out'**
  String get takeOut;

  /// No description provided for @whereItGoes.
  ///
  /// In en, this message translates to:
  /// **'Where it goes'**
  String get whereItGoes;

  /// No description provided for @addsExpenseGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Adds an expense in this category. A \"Savings\" category set to not counted keeps your budget untouched.'**
  String get addsExpenseGoalHint;

  /// No description provided for @goalFromWalletHelp.
  ///
  /// In en, this message translates to:
  /// **'Takes it out of the wallet and into this goal.'**
  String get goalFromWalletHelp;

  /// No description provided for @goalToWalletHelp.
  ///
  /// In en, this message translates to:
  /// **'Puts it back in the wallet as your own money.'**
  String get goalToWalletHelp;

  /// No description provided for @onlyUpdatesGoal.
  ///
  /// In en, this message translates to:
  /// **'Only updates this goal. Nothing is added to your transactions or wallets.'**
  String get onlyUpdatesGoal;

  /// No description provided for @youReachedGoal.
  ///
  /// In en, this message translates to:
  /// **'You reached {goal}!'**
  String youReachedGoal(String goal);

  /// No description provided for @goalReachedBody.
  ///
  /// In en, this message translates to:
  /// **'{target} saved. Bought it? Mark it done and it moves to Done.'**
  String goalReachedBody(String target);

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markAsDone;

  /// No description provided for @deleteThisSaving.
  ///
  /// In en, this message translates to:
  /// **'Delete this saving?'**
  String get deleteThisSaving;

  /// No description provided for @deleteThisTakeOut.
  ///
  /// In en, this message translates to:
  /// **'Delete this take-out?'**
  String get deleteThisTakeOut;

  /// No description provided for @goalGoesDownBy.
  ///
  /// In en, this message translates to:
  /// **'The goal goes down by {amount}.'**
  String goalGoesDownBy(String amount);

  /// No description provided for @goesBackIntoGoal.
  ///
  /// In en, this message translates to:
  /// **'The {amount} goes back into the goal.'**
  String goesBackIntoGoal(String amount);

  /// No description provided for @walletEntryDeletedToo.
  ///
  /// In en, this message translates to:
  /// **'The entry it added in {wallet} is deleted too.'**
  String walletEntryDeletedToo(String wallet);

  /// No description provided for @doneOn.
  ///
  /// In en, this message translates to:
  /// **'Done {date}'**
  String doneOn(String date);

  /// No description provided for @reachedMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Reached — mark it done when you buy it'**
  String get reachedMarkDone;

  /// No description provided for @saveAMonthToReach.
  ///
  /// In en, this message translates to:
  /// **'Save {amount} a month to reach it by {date}'**
  String saveAMonthToReach(String amount, String date);

  /// No description provided for @amountToGo.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String amountToGo(String amount);

  /// No description provided for @saveUpForSomething.
  ///
  /// In en, this message translates to:
  /// **'Save up for something'**
  String get saveUpForSomething;

  /// No description provided for @saveUpForSomethingHelp.
  ///
  /// In en, this message translates to:
  /// **'Add a goal — a new mobile, a bike, a trip — and see how close you are and how much to save each month.'**
  String get saveUpForSomethingHelp;

  /// No description provided for @addAGoal.
  ///
  /// In en, this message translates to:
  /// **'Add a goal'**
  String get addAGoal;

  /// No description provided for @savedForGoals.
  ///
  /// In en, this message translates to:
  /// **'Saved for goals'**
  String get savedForGoals;

  /// No description provided for @stillToSave.
  ///
  /// In en, this message translates to:
  /// **'Still to save'**
  String get stillToSave;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @allGoalsDone.
  ///
  /// In en, this message translates to:
  /// **'All your goals are done.'**
  String get allGoalsDone;

  /// No description provided for @amountOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{amount} of {total}'**
  String amountOfTotal(String amount, String total);

  /// No description provided for @ofTotal.
  ///
  /// In en, this message translates to:
  /// **'of {total}'**
  String ofTotal(String total);

  /// No description provided for @toGo.
  ///
  /// In en, this message translates to:
  /// **'To go'**
  String get toGo;

  /// No description provided for @saveEachMonth.
  ///
  /// In en, this message translates to:
  /// **'Save each month'**
  String get saveEachMonth;

  /// No description provided for @notDoneYet.
  ///
  /// In en, this message translates to:
  /// **'Not done yet'**
  String get notDoneYet;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get addMoney;

  /// No description provided for @goalHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Money you add or take out shows up here.'**
  String get goalHistoryEmpty;

  /// No description provided for @savedBeforeTracking.
  ///
  /// In en, this message translates to:
  /// **'Saved before tracking'**
  String get savedBeforeTracking;

  /// No description provided for @intoWalletNamed.
  ///
  /// In en, this message translates to:
  /// **'Into {wallet}'**
  String intoWalletNamed(String wallet);

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @tookOut.
  ///
  /// In en, this message translates to:
  /// **'Took out'**
  String get tookOut;

  /// No description provided for @amountSaved.
  ///
  /// In en, this message translates to:
  /// **'{amount} saved'**
  String amountSaved(String amount);

  /// No description provided for @nameTheAccount.
  ///
  /// In en, this message translates to:
  /// **'Name the account'**
  String get nameTheAccount;

  /// No description provided for @enterWorthNow.
  ///
  /// In en, this message translates to:
  /// **'Enter what it\'s worth now'**
  String get enterWorthNow;

  /// No description provided for @sameAccountNameBody.
  ///
  /// In en, this message translates to:
  /// **'Two accounts with the same name are easy to mix up. Save anyway?'**
  String get sameAccountNameBody;

  /// No description provided for @deleteInvestAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Its history is deleted. Expenses, income and wallet entries it added are kept.'**
  String get deleteInvestAccountBody;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccount;

  /// No description provided for @newAccount.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get newAccount;

  /// No description provided for @newAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A broker account you invest through. Copy the numbers from your broker\'s app.'**
  String get newAccountSubtitle;

  /// No description provided for @deleteInvestAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteInvestAccount;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccount;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. AKD Trade'**
  String get accountNameHint;

  /// No description provided for @putInSoFar.
  ///
  /// In en, this message translates to:
  /// **'Money you\'ve put in so far'**
  String get putInSoFar;

  /// No description provided for @putInSoFarHelp.
  ///
  /// In en, this message translates to:
  /// **'Everything you deposited, minus anything you took out.'**
  String get putInSoFarHelp;

  /// No description provided for @worthNowLabel.
  ///
  /// In en, this message translates to:
  /// **'What it\'s worth now'**
  String get worthNowLabel;

  /// No description provided for @worthNowHelp.
  ///
  /// In en, this message translates to:
  /// **'Shares plus cash, as your broker\'s app shows it.'**
  String get worthNowHelp;

  /// No description provided for @updateNamed.
  ///
  /// In en, this message translates to:
  /// **'Update {name}'**
  String updateNamed(String name);

  /// No description provided for @updateValueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Copy the total value — shares plus cash — from your broker\'s app.'**
  String get updateValueSubtitle;

  /// No description provided for @saveValue.
  ///
  /// In en, this message translates to:
  /// **'Save value'**
  String get saveValue;

  /// No description provided for @worthNow.
  ///
  /// In en, this message translates to:
  /// **'Worth now'**
  String get worthNow;

  /// No description provided for @accountIsWorth.
  ///
  /// In en, this message translates to:
  /// **'{account} is worth {value}'**
  String accountIsWorth(String account, String value);

  /// No description provided for @investedIn.
  ///
  /// In en, this message translates to:
  /// **'Invested in {account}'**
  String investedIn(String account);

  /// No description provided for @dividendFrom.
  ///
  /// In en, this message translates to:
  /// **'Dividend from {account}'**
  String dividendFrom(String account);

  /// No description provided for @putMoneyIn.
  ///
  /// In en, this message translates to:
  /// **'Put money in'**
  String get putMoneyIn;

  /// No description provided for @putMoneyInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Money you deposited into {account}.'**
  String putMoneyInSubtitle(String account);

  /// No description provided for @takeMoneyOut.
  ///
  /// In en, this message translates to:
  /// **'Take money out'**
  String get takeMoneyOut;

  /// No description provided for @dividend.
  ///
  /// In en, this message translates to:
  /// **'Dividend'**
  String get dividend;

  /// No description provided for @dividendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A dividend from shares in {account}.'**
  String dividendSubtitle(String account);

  /// No description provided for @whereItWent.
  ///
  /// In en, this message translates to:
  /// **'Where it went'**
  String get whereItWent;

  /// No description provided for @incomeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Income this month'**
  String get incomeThisMonth;

  /// No description provided for @addsIncomeHere.
  ///
  /// In en, this message translates to:
  /// **'Adds income in this category.'**
  String get addsIncomeHere;

  /// No description provided for @addsIncomeIn.
  ///
  /// In en, this message translates to:
  /// **'Adds income in {category}.'**
  String addsIncomeIn(String category);

  /// No description provided for @takesItOutOfWallet.
  ///
  /// In en, this message translates to:
  /// **'Takes it out of the wallet.'**
  String get takesItOutOfWallet;

  /// No description provided for @addsToWalletAsYours.
  ///
  /// In en, this message translates to:
  /// **'Adds it to the wallet as your own money.'**
  String get addsToWalletAsYours;

  /// No description provided for @onlyUpdatesAccount.
  ///
  /// In en, this message translates to:
  /// **'Only updates this account. Nothing is added to your transactions or wallets.'**
  String get onlyUpdatesAccount;

  /// No description provided for @deleteThisValue.
  ///
  /// In en, this message translates to:
  /// **'Delete this value?'**
  String get deleteThisValue;

  /// No description provided for @deleteThisDividend.
  ///
  /// In en, this message translates to:
  /// **'Delete this dividend?'**
  String get deleteThisDividend;

  /// No description provided for @deleteThisEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteThisEntry;

  /// No description provided for @valueDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The account goes back to the value before it.'**
  String get valueDeleteBody;

  /// No description provided for @depositDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The {amount} comes off what you put in.'**
  String depositDeleteBody(String amount);

  /// No description provided for @withdrawDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The {amount} goes back into what you put in.'**
  String withdrawDeleteBody(String amount);

  /// No description provided for @dividendDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The {amount} comes off your gain.'**
  String dividendDeleteBody(String amount);

  /// No description provided for @transactionDeletedToo.
  ///
  /// In en, this message translates to:
  /// **'The transaction it added is deleted too.'**
  String get transactionDeletedToo;

  /// No description provided for @valueNotUpdatedYet.
  ///
  /// In en, this message translates to:
  /// **'Value not updated yet'**
  String get valueNotUpdatedYet;

  /// No description provided for @updatedToday.
  ///
  /// In en, this message translates to:
  /// **'Updated today'**
  String get updatedToday;

  /// No description provided for @updatedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Updated yesterday'**
  String get updatedYesterday;

  /// No description provided for @updatedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} days ago'**
  String updatedDaysAgo(int count);

  /// No description provided for @updatedMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Updated a month ago} other{Updated {count} months ago}}'**
  String updatedMonthsAgo(int count);

  /// No description provided for @trackInvestments.
  ///
  /// In en, this message translates to:
  /// **'Track your investments'**
  String get trackInvestments;

  /// No description provided for @trackInvestmentsHelp.
  ///
  /// In en, this message translates to:
  /// **'Add your PSX accounts with what you\'ve put in and what they\'re worth, and see your gain at a glance.'**
  String get trackInvestmentsHelp;

  /// No description provided for @addAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Add an account'**
  String get addAnAccount;

  /// No description provided for @putIn.
  ///
  /// In en, this message translates to:
  /// **'Put in'**
  String get putIn;

  /// No description provided for @gain.
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get gain;

  /// No description provided for @includesDividends.
  ///
  /// In en, this message translates to:
  /// **'Includes {amount} in dividends'**
  String includesDividends(String amount);

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @copyValueHelp.
  ///
  /// In en, this message translates to:
  /// **'Copy each account\'s value from your broker\'s app now and then with Update.'**
  String get copyValueHelp;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @valueUpdated.
  ///
  /// In en, this message translates to:
  /// **'Value updated'**
  String get valueUpdated;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
