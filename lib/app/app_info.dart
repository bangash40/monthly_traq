/// Public facts about the app, kept in one place: the store listing, the
/// About section and the privacy policy all read from here.
class AppInfo {
  static const name = 'MonthlyTraq';

  /// The Android application ID. Permanent once published on Google Play.
  static const packageName = 'com.monthlytraq.app';

  static const supportEmail = 'farhanbangash40@gmail.com';

  static const privacyPolicyEffectiveDate = 'September 28, 2026';

  /// Opens the listing in the Play Store app.
  static final playStoreAppUri = Uri.parse('market://details?id=$packageName');

  /// The same listing in a browser, for phones without the Play Store.
  static final playStoreWebUri = Uri.parse(
    'https://play.google.com/store/apps/details?id=$packageName',
  );

  static Uri supportEmailUri({String subject = '$name support'}) => Uri(
    scheme: 'mailto',
    path: supportEmail,
    query: 'subject=${Uri.encodeComponent(subject)}',
  );
}
