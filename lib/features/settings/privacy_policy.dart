import 'package:monthly_traq/app/app_info.dart';

/// One section of the privacy policy: a heading, paragraphs, and an
/// optional bullet list.
class PolicySection {
  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;

  const PolicySection(this.heading, this.paragraphs, [this.bullets = const []]);
}

/// The privacy policy shown in the app. The hosted copy for the Play Store
/// listing is store/privacy-policy.html — keep the two in sync.
const privacyPolicy = [
  PolicySection('About this policy', [
    '${AppInfo.name} is a personal budgeting app. This policy explains what '
        'information the app collects, how it is used, and the choices you '
        'have. It applies to the ${AppInfo.name} Android app.',
  ]),
  PolicySection('What we collect', [], [
    'Account information: your name and email address. If you sign in with '
        'Google, we receive the name and email address of your Google '
        'account. Passwords are handled by Firebase Authentication and are '
        'never visible to us.',
    'What you enter: your transactions (amount, note, category and date), '
        'your categories, your monthly budget, the day your budget month '
        'starts, and your currency.',
    'Wallets: the wallets you add (name and balance), what you record in '
        'them (amounts, dates and notes), and the people whose money you '
        'keep — the name you give each person and the amounts received from '
        'and sent back to them.',
    'Profile photo: if you add one, a compressed copy is stored with your '
        'account.',
    'Settings on your device: your theme, text size and similar '
        'preferences are stored only on your phone and are never uploaded.',
    'Technical data: Google Firebase processes the technical information '
        'needed to sign you in and keep your data in sync, such as an app '
        'installation ID and your IP address.',
  ]),
  PolicySection('How we use it', [
    'Only to run the app: to sign you in, store your data and keep it in '
        'sync across your devices, and show your budget and reports.',
    'We do not show ads, we do not use your data for advertising, and we do '
        'not sell or rent your data to anyone. The app contains no '
        'advertising or analytics software.',
  ]),
  PolicySection('Where it is stored', [
    'Your data is stored with Google Firebase (Firebase Authentication and '
        'Cloud Firestore), which acts as our service provider. It is '
        'encrypted in transit and at rest, and security rules allow each '
        'account to access only its own data. We share your data with no '
        'one else, unless the law requires it.',
  ]),
  PolicySection(
    'Keeping and deleting your data',
    ['We keep your data for as long as you have an account.'],
    [
      'To delete your account in the app, go to Profile → Data → Delete '
          'account. This permanently deletes your transactions, categories, '
          'wallets, the people in them, budget, currency, profile photo and '
          'sign-in. It cannot be undone.',
      'To delete only your transactions and keep your account, use '
          'Profile → Data → Delete all data.',
      'If you can no longer use the app, email ${AppInfo.supportEmail} from '
          'the address you signed up with, with the subject "Delete my '
          'account". We will delete your account and all its data within 30 '
          'days and confirm by email.',
    ],
  ),
  PolicySection('Children', [
    '${AppInfo.name} is not directed to children under 13, and we do not '
        'knowingly collect information from them. If you believe a child '
        'has created an account, contact us and we will delete it.',
  ]),
  PolicySection('Changes to this policy', [
    'If this policy changes, we will update this page and the effective '
        'date below.',
  ]),
  PolicySection('Contact', [
    'Questions or requests about your data: ${AppInfo.supportEmail}',
    'Effective ${AppInfo.privacyPolicyEffectiveDate}.',
  ]),
];
