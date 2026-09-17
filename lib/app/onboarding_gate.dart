import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monthly_traq/app/auth_gate.dart';
import 'package:monthly_traq/features/onboarding/onboarding_screen.dart';

const _seenOnboardingKey = 'has_seen_onboarding';

/// Shows the onboarding carousel once, on the very first launch after
/// install, then remembers that locally (per-device, not per-account) and
/// goes straight to [AuthGate] on every launch after that.
class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool? _hasSeenOnboarding;
  bool _justFinishedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenOnboarding = prefs.getBool(_seenOnboardingKey) ?? false;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenOnboardingKey, true);
    setState(() {
      _hasSeenOnboarding = true;
      _justFinishedOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasSeenOnboarding!) {
      return OnboardingScreen(onDone: _completeOnboarding);
    }

    return AuthGate(startOnSignup: _justFinishedOnboarding);
  }
}
