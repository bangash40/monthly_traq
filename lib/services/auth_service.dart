import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await credential.user?.reload();
    return credential;
  }

  /// Signs in with Google, creating a Firebase account automatically the
  /// first time. Returns null if the user cancels the account picker.
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _firebaseAuth.signInWithCredential(credential);
  }

  bool _hasProvider(String id) =>
      _firebaseAuth.currentUser?.providerData.any((p) => p.providerId == id) ??
      false;

  /// True when the account signs in with an email and password (it may
  /// also be linked to Google).
  bool get usesPassword => _hasProvider(EmailAuthProvider.PROVIDER_ID);

  /// Re-checks the password just before a sensitive action like deleting
  /// the account, which Firebase only allows right after signing in.
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _firebaseAuth.currentUser!;
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: password),
    );
  }

  /// Same as [reauthenticateWithPassword], via the Google account picker.
  /// Returns false if the user cancels.
  Future<bool> reauthenticateWithGoogle() async {
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow;
    }
    await _firebaseAuth.currentUser!.reauthenticateWithCredential(
      GoogleAuthProvider.credential(idToken: account.authentication.idToken),
    );
    return true;
  }

  /// Permanently deletes the signed-in account. Delete the user's data
  /// first — once this succeeds, the rules no longer let anyone reach it.
  Future<void> deleteCurrentUser() async {
    await _firebaseAuth.currentUser?.delete();
    await GoogleSignIn.instance.signOut();
  }

  /// Emails a link to reset the password for [email].
  Future<void> sendPasswordReset(String email) =>
      _firebaseAuth.sendPasswordResetEmail(email: email);

  Future<void> updateDisplayName(String name) async {
    await _firebaseAuth.currentUser?.updateDisplayName(name);
    await _firebaseAuth.currentUser?.reload();
  }

  Future<void> updatePhotoUrl(String? url) async {
    await _firebaseAuth.currentUser?.updatePhotoURL(url);
    await _firebaseAuth.currentUser?.reload();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn.instance.signOut();
  }

  User? get currentUser => _firebaseAuth.currentUser;
}
