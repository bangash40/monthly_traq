import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // The web OAuth client from google-services.json — required as
  // serverClientId on Android since this project doesn't apply the Google
  // Services Gradle plugin (which would otherwise supply it automatically).
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '720765164093-v7o953fpvbc0d1ubptp3l24dg94pjqaa.apps.googleusercontent.com',
  );

  runApp(const MonthlyTraqApp());
}
