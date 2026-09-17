import 'package:flutter/material.dart';

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

const onboardingSlides = [
  OnboardingSlide(
    icon: Icons.receipt_long,
    title: 'Track Every Transaction',
    subtitle: 'Log income and expenses in seconds, organized by category.',
  ),
  OnboardingSlide(
    icon: Icons.pie_chart,
    title: 'See Where It Goes',
    subtitle:
        'Visual breakdowns show exactly how much you\'re spending, and where.',
  ),
  OnboardingSlide(
    icon: Icons.account_balance_wallet,
    title: 'Set a Monthly Budget',
    subtitle: 'Set a spending limit and get a live meter as you go.',
  ),
  OnboardingSlide(
    icon: Icons.show_chart,
    title: 'Watch Your Trends',
    subtitle: 'Compare income and expenses month over month at a glance.',
  ),
  OnboardingSlide(
    icon: Icons.cloud_done,
    title: 'Always Synced',
    subtitle: 'Your data is securely backed up and available on any device.',
  ),
];
