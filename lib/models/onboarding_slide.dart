import 'package:monthly_traq/l10n/app_localizations.dart';

/// Which illustration a slide shows.
enum OnboardingArt { transactions, breakdown, budget, trends, sync }

/// One onboarding slide: its illustration, with a title and a line of text
/// in the current language.
class OnboardingSlide {
  final OnboardingArt art;

  const OnboardingSlide(this.art);

  String title(AppLocalizations l10n) => switch (art) {
    OnboardingArt.transactions => l10n.onboardingTitleTransactions,
    OnboardingArt.breakdown => l10n.onboardingTitleBreakdown,
    OnboardingArt.budget => l10n.onboardingTitleBudget,
    OnboardingArt.trends => l10n.onboardingTitleTrends,
    OnboardingArt.sync => l10n.onboardingTitleSync,
  };

  String body(AppLocalizations l10n) => switch (art) {
    OnboardingArt.transactions => l10n.onboardingBodyTransactions,
    OnboardingArt.breakdown => l10n.onboardingBodyBreakdown,
    OnboardingArt.budget => l10n.onboardingBodyBudget,
    OnboardingArt.trends => l10n.onboardingBodyTrends,
    OnboardingArt.sync => l10n.onboardingBodySync,
  };
}

const onboardingSlides = [
  OnboardingSlide(OnboardingArt.transactions),
  OnboardingSlide(OnboardingArt.breakdown),
  OnboardingSlide(OnboardingArt.budget),
  OnboardingSlide(OnboardingArt.trends),
  OnboardingSlide(OnboardingArt.sync),
];
