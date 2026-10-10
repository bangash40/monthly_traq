// Form checks for the login and sign-up screens: email format, likely typos
// in the email's domain, and the rules a new password has to meet.

import 'package:monthly_traq/l10n/app_localizations.dart';

final _localPart = RegExp(r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~.-]+$");
final _domainLabel = RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$');
final _topLevelDomain = RegExp(r'^[A-Za-z]{2,}$');

String? validateEmail(AppLocalizations l10n, String? value) {
  final invalidEmail = l10n.emailInvalid;
  final email = value?.trim() ?? '';
  if (email.isEmpty) return l10n.emailRequired;
  if (email.contains(RegExp(r'\s'))) {
    return l10n.emailHasSpaces;
  }

  final parts = email.split('@');
  if (parts.length != 2) return invalidEmail;
  final [local, domain] = parts;

  if (local.isEmpty ||
      local.length > 64 ||
      !_localPart.hasMatch(local) ||
      local.startsWith('.') ||
      local.endsWith('.') ||
      local.contains('..')) {
    return invalidEmail;
  }

  final labels = domain.split('.');
  if (labels.length < 2 ||
      !labels.every(_domainLabel.hasMatch) ||
      !_topLevelDomain.hasMatch(labels.last)) {
    return invalidEmail;
  }
  return null;
}

/// Validator for the email on the sign-up form: [validateEmail], plus it
/// turns away placeholder and temporary addresses, which can never receive
/// a password-reset email. Login uses plain [validateEmail] so accounts made
/// before this check still get in.
String? validateSignupEmail(AppLocalizations l10n, String? value) {
  final formatProblem = validateEmail(l10n, value);
  if (formatProblem != null) return formatProblem;

  final email = value!.trim().toLowerCase();
  final domain = email.substring(email.indexOf('@') + 1);
  bool isOrUnder(String blocked) =>
      domain == blocked || domain.endsWith('.$blocked');

  // Placeholder names are caught whatever the ending, so "test.om",
  // "test.co" and "mail.example.pk" are all turned away, not just
  // "test.com".
  final labels = domain.split('.');
  final names = labels.sublist(0, labels.length - 1);
  if (_reservedEndings.contains(labels.last) ||
      names.any(_placeholderNames.contains)) {
    return l10n.emailPlaceholder;
  }
  if (_temporaryEmailDomains.any(isOrUnder)) {
    return l10n.emailTemporary;
  }
  return null;
}

/// Endings reserved for examples and testing, which never have real inboxes.
const _reservedEndings = {'test', 'example', 'invalid', 'localhost', 'local'};

/// Domain names people type when they don't want to give a real address,
/// matched with any ending (.com, .om, .pk…).
const _placeholderNames = {
  'example', 'test', 'tests', 'testing', 'tester', 'fake', 'fakeemail', //
  'fakemail', 'dummy', 'sample', 'demo', 'temp', 'noemail', 'nomail',
  'no-email', 'none', 'null', 'invalid', 'domain', 'mydomain', 'yourdomain',
  'youremail', 'yourmail', 'asdf', 'asdfgh', 'qwerty', 'abc', 'abcd', 'xyz',
  'aaa', 'abc123',
};

/// Throwaway-inbox services.
const _temporaryEmailDomains = {
  'mailinator.com', 'guerrillamail.com', 'guerrillamail.net', //
  'guerrillamail.org', 'guerrillamailblock.com', 'sharklasers.com', 'grr.la',
  '10minutemail.com', '10minutemail.net', 'temp-mail.org', 'temp-mail.io',
  'tempmail.com', 'tempmail.net', 'tempmailo.com', 'tempr.email',
  'tempinbox.com', 'tmpmail.org', 'tmpmail.net', 'yopmail.com', 'yopmail.net',
  'trashmail.com', 'trashmail.de', 'getnada.com', 'nada.email',
  'dispostable.com', 'maildrop.cc', 'throwawaymail.com', 'fakeinbox.com',
  'mailnesia.com', 'mintemail.com', 'emailondeck.com', 'moakt.com',
  'burnermail.io', 'mytemp.email', 'mohmal.com', 'spamgourmet.com',
  'mailcatch.com', 'mailpoof.com', 'discard.email', 'emailfake.com',
  'fakemailgenerator.com', 'inboxkitten.com', '1secmail.com', '1secmail.net',
  '1secmail.org', 'spam4.me', 'harakirimail.com', 'mailsac.com',
  'anonbox.net',
};

/// Popular email providers, most common first, so a typo that is equally
/// close to two of them is corrected to the likelier one.
const _knownDomains = [
  'gmail.com',
  'yahoo.com',
  'hotmail.com',
  'outlook.com',
  'icloud.com',
  'live.com',
  'aol.com',
  'msn.com',
  'googlemail.com',
  'protonmail.com',
  'proton.me',
  'ymail.com',
  'me.com',
  'mail.com',
  'gmx.com',
  'zoho.com',
  'yandex.com',
  'yahoo.co.uk',
  'hotmail.co.uk',
];

/// Endings people type when they mean ".com".
const _comTypos = {
  'co', 'con', 'cmo', 'ocm', 'cm', 'om', 'comm', 'coom', 'vom', 'xom', //
  'cpm', 'cim', 'clm', 'comn', 'c0m',
};

/// If the email's domain looks like a misspelling of a popular provider
/// ("ali@gmial.com"), returns the corrected address ("ali@gmail.com");
/// otherwise null.
///
/// The provider name ("gmail") and the ending ("com") are compared
/// separately, so a correctly typed provider with a regional ending
/// ("yahoo.com.pk", "hotmail.fr") is left alone.
String? emailTypoSuggestion(String? value) {
  final email = value?.trim() ?? '';
  final at = email.lastIndexOf('@');
  if (at <= 0 || at == email.length - 1 || email.indexOf('@') != at) {
    return null;
  }
  final local = email.substring(0, at);
  final domain = email.substring(at + 1).toLowerCase();
  if (_knownDomains.contains(domain)) return null;

  // "ali@gmail" or "ali@gmailcom" — the ending was left off or lost its dot.
  if (!domain.contains('.')) {
    final name = domain.endsWith('com')
        ? domain.substring(0, domain.length - 3)
        : domain;
    return _knownDomains.contains('$name.com') ? '$local@$name.com' : null;
  }

  final (name, ending) = _splitDomain(domain);
  String? best;
  var bestScore = 1 << 30;
  for (final known in _knownDomains) {
    final (knownName, knownEnding) = _splitDomain(known);
    final endingFits =
        ending == knownEnding ||
        (knownEnding == 'com' && _comTypos.contains(ending));
    if (!endingFits) continue;

    // Short names get less leeway, so "aol" doesn't swallow unrelated
    // three-letter domains.
    final nameEdits = _editDistance(name, knownName);
    if (nameEdits > (knownName.length <= 4 ? 1 : 2)) continue;

    final score = nameEdits + (ending == knownEnding ? 0 : 1);
    if (score < bestScore) {
      best = known;
      bestScore = score;
    }
  }
  if (best != null) return '$local@$best';

  // Any other domain with a slipped ".com" ("company.con", "shop.om").
  // ".co" is left alone here — plenty of real sites use it.
  if (ending != 'co' && _comTypos.contains(ending)) {
    return '$local@$name.com';
  }
  return null;
}

/// "yahoo.co.uk" → ("yahoo", "co.uk").
(String, String) _splitDomain(String domain) {
  final dot = domain.indexOf('.');
  return (domain.substring(0, dot), domain.substring(dot + 1));
}

/// Number of single-character insertions, deletions, substitutions or
/// swaps of neighbouring characters needed to turn [a] into [b].
int _editDistance(String a, String b) {
  final d = List.generate(
    a.length + 1,
    (i) => List.generate(b.length + 1, (j) => i == 0 ? j : (j == 0 ? i : 0)),
  );
  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      var best = [
        d[i - 1][j] + 1,
        d[i][j - 1] + 1,
        d[i - 1][j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
      if (i > 1 &&
          j > 1 &&
          a[i - 1] == b[j - 2] &&
          a[i - 2] == b[j - 1] &&
          d[i - 2][j - 2] + 1 < best) {
        best = d[i - 2][j - 2] + 1;
      }
      d[i][j] = best;
    }
  }
  return d[a.length][b.length];
}

const minPasswordLength = 8;

enum PasswordStrength { empty, weak, okay, strong }

/// How strong a new password is and, when it can't be used, why.
class PasswordCheck {
  final PasswordStrength strength;

  /// Why the password can't be used; null when it's acceptable.
  final String? problem;

  const PasswordCheck(this.strength, [this.problem]);
}

/// Checks a new password the way modern sign-up forms do: a minimum length,
/// no well-known or easy-to-guess passwords, and not the person's own name
/// or email — rather than demanding a mix of character types, which mostly
/// produces predictable passwords like "Password1!".
PasswordCheck checkNewPassword(
  AppLocalizations l10n,
  String password, {
  String name = '',
  String email = '',
}) {
  if (password.isEmpty) return const PasswordCheck(PasswordStrength.empty);

  PasswordCheck weak(String problem) =>
      PasswordCheck(PasswordStrength.weak, problem);

  if (password.trim() != password) {
    return weak(l10n.passwordSpaceAtEnds);
  }
  if (password.length < minPasswordLength) {
    return weak(l10n.passwordTooShort(minPasswordLength));
  }
  if (RegExp(r'^\d+$').hasMatch(password) && password.length < 12) {
    return weak(l10n.passwordOnlyNumbers);
  }
  if (_isEasyToGuess(password)) {
    return weak(l10n.passwordTooCommon);
  }
  if (_containsPersonalInfo(password, name: name, email: email)) {
    return weak(l10n.passwordPersonal);
  }

  final kinds = [
    RegExp('[a-z]'),
    RegExp('[A-Z]'),
    RegExp('[0-9]'),
    RegExp(r'[^A-Za-z0-9]'),
  ].where((kind) => kind.hasMatch(password)).length;
  final length = password.length;
  final strong =
      length >= 14 ||
      (length >= 12 && kinds >= 2) ||
      (length >= 10 && kinds >= 3);
  return PasswordCheck(
    strong ? PasswordStrength.strong : PasswordStrength.okay,
  );
}

/// Validator for choosing a new password.
String? validateNewPassword(
  AppLocalizations l10n,
  String? value, {
  String name = '',
  String email = '',
}) {
  final check = checkNewPassword(l10n, value ?? '', name: name, email: email);
  if (check.strength == PasswordStrength.empty) return l10n.passwordRequired;
  return check.problem;
}

bool _isEasyToGuess(String password) {
  final lower = password.toLowerCase();

  // One character or a short chunk repeated: "aaaaaaaa", "abcabcabc".
  for (var size = 1; size <= 4; size++) {
    if (lower.length % size == 0 &&
        lower == lower.substring(0, size) * (lower.length ~/ size)) {
      return true;
    }
  }

  // A straight run along the alphabet, the digits or a keyboard row:
  // "12345678", "abcdefgh", "qwertyui", "87654321".
  for (final run in _runs) {
    if (run.contains(lower) || run.split('').reversed.join().contains(lower)) {
      return true;
    }
  }

  // A well-known word with numbers or symbols tacked on, including
  // look-alike swaps: "password123", "P@ssw0rd!", "pakistan786".
  final core = lower
      .replaceAll(RegExp(r'^\d+|[\d\W_]+$'), '')
      .replaceAllMapped(RegExp(r'[@4031$5!7]'), (m) => _lookAlikes[m[0]!]!);
  return _commonPasswords.contains(lower) || _commonPasswords.contains(core);
}

const _lookAlikes = {
  '@': 'a',
  '4': 'a',
  '0': 'o',
  '3': 'e',
  '1': 'i',
  r'$': 's',
  '5': 's',
  '!': 'i',
  '7': 't',
};

const _runs = [
  '01234567890',
  'abcdefghijklmnopqrstuvwxyz',
  'qwertyuiopasdfghjklzxcvbnm',
  '1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p',
];

bool _containsPersonalInfo(
  String password, {
  required String name,
  required String email,
}) {
  final lower = password.toLowerCase();
  final at = email.indexOf('@');
  final local = at > 0 ? email.substring(0, at) : '';
  // Pieces shorter than 4 letters are skipped, so a name like "Ali"
  // doesn't block every password that happens to contain "ali".
  final pieces = {
    ...name.toLowerCase().split(RegExp(r'\s+')),
    local.toLowerCase(),
    ...local.toLowerCase().split(RegExp(r'[._+\-\d]+')),
  }.where((piece) => piece.length >= 4);
  return pieces.any(lower.contains);
}

/// Passwords (and password "cores", once trailing numbers and symbols are
/// stripped) that appear near the top of leaked-password lists, plus local
/// favourites. Lowercase.
const _commonPasswords = {
  'password', 'passw0rd', 'pass', 'passwd', 'passcode', 'mypassword',
  'qwerty', 'qwertyuiop', 'asdf', 'asdfgh', 'asdfghjkl', 'zxcvbnm', //
  'qazwsx', 'zaq', 'zaqxsw', '1q2w3e', '1q2w3e4r', '1qaz2wsx', 'abc', 'abcd',
  'abcdef', 'iloveyou', 'loveyou', 'love', 'lovely', 'welcome', 'hello',
  'helloworld', 'admin', 'administrator', 'root', 'user', 'guest', 'login',
  'letmein', 'test', 'testing', 'default', 'secret', 'changeme', 'master',
  'monkey', 'dragon', 'shadow', 'sunshine', 'princess', 'superman', 'batman',
  'starwars', 'pokemon', 'naruto', 'football', 'baseball', 'soccer',
  'cricket', 'hockey', 'trustno', 'whatever', 'freedom', 'computer',
  'internet', 'google', 'samsung', 'iphone', 'android', 'facebook',
  'instagram', 'whatsapp', 'michael', 'jordan', 'charlie', 'daniel',
  'jessica', 'ashley', 'killer', 'hunter', 'ranger', 'summer', 'winter',
  'flower', 'cookie', 'cheese', 'mustang', 'ferrari', 'liverpool', 'arsenal',
  'chelsea', 'barcelona', 'realmadrid', 'manchester', 'access', 'money',
  'family', 'friends', 'budget', 'monthly', 'monthlytraq', 'pakistan',
  'pakistanzindabad', 'lahore', 'karachi', 'islamabad', 'india', 'bismillah',
  'allah', 'muhammad', 'qwerty123', 'password123', 'iloveyou123', 'abc123',
};
