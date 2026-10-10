import 'dart:async';

/// Whether Firestore last served the app from the phone's own copy
/// because it couldn't reach the server. Kept up to date by
/// TransactionsRepository's live listeners.
bool firestoreOffline = false;

/// How long a write waits for the server while online, so a write the
/// server rejects still shows up as an error.
const _serverWait = Duration(seconds: 3);

/// Called when a save or delete is kept on the phone because there's no
/// connection; the app shows a short note. Set by the app at startup.
void Function()? onSavedOffline;

DateTime? _lastNote;

/// One note per action: an action that writes several things (a payment
/// and its expense) or a few quick saves in a row only note it once.
void _noteSavedOffline() {
  final now = DateTime.now();
  final last = _lastNote;
  if (last != null && now.difference(last) < const Duration(seconds: 6)) {
    return;
  }
  _lastNote = now;
  onSavedOffline?.call();
}

/// Waits for a save or delete just long enough.
///
/// Firestore applies every write to the phone's copy the moment it's made —
/// lists, totals and balances update straight away — and sends it to the
/// server when it can, even after the app restarts. So a write is done as
/// far as the person is concerned once it's on the phone.
///
/// Offline this doesn't wait at all. Online it gives the server a moment,
/// so a rejected write (bad data, security rules) still throws; if the
/// server is just slow, the write finishes in the background.
Future<void> settleWrite(Future<void> write) async {
  if (firestoreOffline) {
    write.ignore();
    _noteSavedOffline();
    return;
  }
  // Still no answer after a moment: most likely the connection just
  // dropped and Firestore hasn't said so yet.
  await write.timeout(_serverWait, onTimeout: _noteSavedOffline);
}
