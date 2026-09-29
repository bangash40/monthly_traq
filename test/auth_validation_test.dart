import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monthly_traq/features/auth/auth_validation.dart';
import 'package:monthly_traq/services/auth_errors.dart';

void main() {
  group('validateEmail', () {
    test('accepts ordinary addresses', () {
      for (final email in [
        'ali@gmail.com',
        '  ali@gmail.com  ',
        'first.last+budget@company.co.uk',
        'a_b-c@sub-domain.example.pk',
      ]) {
        expect(validateEmail(email), isNull, reason: email);
      }
    });

    test('asks for an email when empty', () {
      expect(validateEmail(''), 'Enter your email address');
      expect(validateEmail(null), 'Enter your email address');
      expect(validateEmail('   '), 'Enter your email address');
    });

    test('rejects spaces inside the address', () {
      expect(validateEmail('ali @gmail.com'), contains('spaces'));
    });

    test('rejects malformed addresses', () {
      for (final email in [
        'ali',
        'ali@',
        '@gmail.com',
        'ali@@gmail.com',
        'ali@gmail@yahoo.com',
        'ali@gmail',
        'ali@gmail.c',
        'ali@gmail.123',
        'ali@.com',
        'ali@gmail..com',
        'ali@-gmail.com',
        'ali@gmail-.com',
        '.ali@gmail.com',
        'ali.@gmail.com',
        'a..li@gmail.com',
        'ali(x)@gmail.com',
      ]) {
        expect(
          validateEmail(email),
          'Enter a valid email address, like name@example.com',
          reason: email,
        );
      }
    });
  });

  group('emailTypoSuggestion', () {
    test('fixes common misspellings of popular providers', () {
      expect(emailTypoSuggestion('ali@gmial.com'), 'ali@gmail.com');
      expect(emailTypoSuggestion('ali@gamil.com'), 'ali@gmail.com');
      expect(emailTypoSuggestion('ali@gmail.con'), 'ali@gmail.com');
      expect(emailTypoSuggestion('ali@gmail.co'), 'ali@gmail.com');
      expect(emailTypoSuggestion('ali@gmai.com'), 'ali@gmail.com');
      expect(emailTypoSuggestion('ali@yaho.com'), 'ali@yahoo.com');
      expect(emailTypoSuggestion('ali@hotmial.com'), 'ali@hotmail.com');
      expect(emailTypoSuggestion('ali@outlok.com'), 'ali@outlook.com');
      expect(emailTypoSuggestion('ali@iclod.com'), 'ali@icloud.com');
    });

    test('adds a missing .com or its missing dot', () {
      expect(emailTypoSuggestion('ali@gmail'), 'ali@gmail.com');
      expect(emailTypoSuggestion('ali@hotmail'), 'ali@hotmail.com');
      expect(emailTypoSuggestion('ali@gmailcom'), 'ali@gmail.com');
    });

    test('fixes a slipped .com on any domain', () {
      expect(emailTypoSuggestion('email@test.om'), 'email@test.com');
      expect(emailTypoSuggestion('ali@company.con'), 'ali@company.com');
      expect(emailTypoSuggestion('ali@company.cmo'), 'ali@company.com');
      // .co is a real ending that many sites use, so it's left alone.
      expect(emailTypoSuggestion('ali@company.co'), isNull);
      expect(emailTypoSuggestion('ali@company.co.uk'), isNull);
    });

    test('fixes misspelled providers with regional endings', () {
      expect(emailTypoSuggestion('ali@hotmial.co.uk'), 'ali@hotmail.co.uk');
    });

    test('keeps the part before @ exactly as typed', () {
      expect(emailTypoSuggestion(' Ali.Khan@GMIAL.com '), 'Ali.Khan@gmail.com');
    });

    test('leaves correct and unrelated domains alone', () {
      for (final email in [
        'ali@gmail.com',
        'ali@GMAIL.COM',
        'ali@mail.com',
        'ali@me.com',
        'ali@ymail.com',
        'ali@company.com',
        'ali@yahoo.com.pk',
        'ali@hotmail.fr',
        'ali@university.edu.pk',
      ]) {
        expect(emailTypoSuggestion(email), isNull, reason: email);
      }
    });

    test('ignores text that is not an email yet', () {
      for (final email in ['', 'ali', 'ali@', '@gmial.com', 'a@b@gmial.com']) {
        expect(emailTypoSuggestion(email), isNull, reason: email);
      }
    });
  });

  group('validateSignupEmail', () {
    test('accepts real-looking addresses', () {
      for (final email in [
        'ali@gmail.com',
        'sara.khan@company.pk',
        'ali@yahoo.com.pk',
        'ali@email.com',
        'someone@yazeed.com',
      ]) {
        expect(validateSignupEmail(email), isNull, reason: email);
      }
    });

    test('still runs the format check first', () {
      expect(validateSignupEmail('ali@gmail'), contains('valid email'));
    });

    test('turns away placeholder addresses', () {
      for (final email in [
        'ali@example.com',
        'ali@EXAMPLE.org',
        'ali@test.com',
        'ali@mail.test.com',
        'ali@fake.com',
        'ali@noemail.com',
        'ali@anything.test',
        'ali@anything.invalid',
        // Placeholder names are caught whatever the ending.
        'email@test.om',
        'ali@test.co',
        'ali@test.pk',
        'ali@example.co.uk',
        'ali@mail.test.org',
        'ali@fake.net',
        'ali@abc.xyz',
      ]) {
        expect(
          validateSignupEmail(email),
          startsWith('Use your real email address'),
          reason: email,
        );
      }
    });

    test('turns away temporary inboxes', () {
      for (final email in [
        'ali@mailinator.com',
        'ali@yopmail.com',
        'ali@10minutemail.com',
        'ali@guerrillamail.com',
      ]) {
        expect(
          validateSignupEmail(email),
          startsWith('Temporary emails can\'t be used'),
          reason: email,
        );
      }
    });

    test('login keeps accepting them, so older accounts still get in', () {
      expect(validateEmail('ali@example.com'), isNull);
      expect(validateEmail('ali@test.com'), isNull);
    });
  });

  group('checkNewPassword', () {
    PasswordStrength strength(String p) => checkNewPassword(p).strength;

    test('empty', () {
      expect(strength(''), PasswordStrength.empty);
      expect(validateNewPassword(''), 'Create a password');
      expect(validateNewPassword(null), 'Create a password');
    });

    test('needs at least 8 characters', () {
      expect(validateNewPassword('Tk9#mz'), 'Use at least 8 characters');
      expect(strength('Tk9#mz'), PasswordStrength.weak);
    });

    test('does not demand uppercase, numbers or symbols', () {
      expect(validateNewPassword('tealkettle'), isNull);
      expect(validateNewPassword('rainy tuesday lunch'), isNull);
    });

    test('rejects leading or trailing spaces', () {
      expect(validateNewPassword(' tealkettle'), contains('space'));
      expect(validateNewPassword('tealkettle '), contains('space'));
    });

    test('rejects short all-number passwords', () {
      expect(validateNewPassword('03001234567'), contains('numbers alone'));
      expect(validateNewPassword('20262026'), isNotNull);
    });

    test('rejects common and easy-to-guess passwords', () {
      for (final password in [
        'password',
        'Password1!',
        'P@ssw0rd',
        'p@ssw0rd123',
        'password2026',
        'iloveyou',
        'qwerty123',
        'qwertyuiop',
        'asdfghjkl',
        'abcdefgh',
        'abcdefghij',
        '1q2w3e4r',
        'pakistan786',
        'Pakistan@123',
        'bismillah',
        'monthlytraq1',
        'aaaaaaaa',
        'abcabcabc',
        'abcdabcd',
      ]) {
        expect(
          validateNewPassword(password),
          'This password is too common. Try something harder to guess',
          reason: password,
        );
      }
    });

    test('a common word inside a longer phrase is fine', () {
      expect(validateNewPassword('LoveMyKids2026'), isNull);
      expect(validateNewPassword('cricket at sunset'), isNull);
    });

    test('rejects the person\'s own name or email', () {
      String? check(String p) => validateNewPassword(
        p,
        name: 'Farhan Haider',
        email: 'farhan.b@gmail.com',
      );
      expect(check('farhan2026!'), contains('name or email'));
      expect(check('xHaider#99'), contains('name or email'));
      expect(check('tealkettle'), isNull);
    });

    test('short names are not checked, so "Ali" does not block "Italian"', () {
      expect(
        validateNewPassword('Italian2026', name: 'Ali', email: 'ali@x.com'),
        isNull,
      );
    });

    test('okay vs strong', () {
      expect(strength('tealkettle'), PasswordStrength.okay);
      expect(strength('Tk9#mzq2'), PasswordStrength.okay);
      expect(strength('Teal-kettle9'), PasswordStrength.strong);
      expect(strength('tealkettle29'), PasswordStrength.strong);
      expect(strength('rainy tuesday lunch'), PasswordStrength.strong);
    });

    test('an accepted password never has a problem', () {
      for (final p in ['tealkettle', 'Teal-kettle9', 'rainy tuesday lunch']) {
        expect(checkNewPassword(p).problem, isNull, reason: p);
      }
    });
  });

  group('authErrorMessage', () {
    FirebaseAuthException auth(String code) =>
        FirebaseAuthException(code: code, message: 'raw firebase text');

    test('wrong login details depend on what the user was doing', () {
      for (final code in ['invalid-credential', 'wrong-password']) {
        expect(
          authErrorMessage(auth(code), AuthAction.logIn),
          'That email and password don\'t match an account.',
        );
        expect(
          authErrorMessage(auth(code), AuthAction.confirmIdentity),
          'That password isn\'t right.',
        );
      }
    });

    test('common failures get friendly messages', () {
      expect(
        authErrorMessage(auth('network-request-failed'), AuthAction.logIn),
        startsWith('No internet connection'),
      );
      expect(
        authErrorMessage(auth('too-many-requests'), AuthAction.logIn),
        startsWith('Too many attempts'),
      );
      expect(
        authErrorMessage(auth('email-already-in-use'), AuthAction.signUp),
        'That email already has an account. Log in instead.',
      );
      expect(
        authErrorMessage(auth('user-disabled'), AuthAction.logIn),
        contains('turned off'),
      );
      expect(
        authErrorMessage(
          auth('password-does-not-meet-requirements'),
          AuthAction.signUp,
        ),
        'Choose a stronger password.',
      );
    });

    test('never shows raw Firebase text', () {
      final message = authErrorMessage(
        auth('some-new-code'),
        AuthAction.signUp,
      );
      expect(message, isNot(contains('raw firebase text')));
      expect(message, startsWith('Couldn\'t create your account.'));
    });

    test('non-Firebase errors fall back to the action message', () {
      expect(
        authErrorMessage(Exception('boom'), AuthAction.resetPassword),
        'Couldn\'t send the reset email. Please try again.',
      );
    });

    test('Google sign-in errors', () {
      expect(
        authErrorMessage(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.uiUnavailable,
          ),
          AuthAction.google,
        ),
        contains('Use your email instead'),
      );
      expect(
        authErrorMessage(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.unknownError,
          ),
          AuthAction.google,
        ),
        startsWith('Couldn\'t sign in with Google.'),
      );
    });
  });
}
