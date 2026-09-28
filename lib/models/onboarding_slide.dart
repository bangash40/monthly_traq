/// Which illustration a slide shows.
enum OnboardingArt { transactions, breakdown, budget, trends, sync }

class OnboardingSlide {
  final OnboardingArt art;
  final String title;
  final String body;

  const OnboardingSlide({
    required this.art,
    required this.title,
    required this.body,
  });
}

const onboardingSlides = [
  OnboardingSlide(
    art: OnboardingArt.transactions,
    title: 'Every rupee, in one place',
    body: 'Log income and expenses in seconds, sorted by category.',
  ),
  OnboardingSlide(
    art: OnboardingArt.breakdown,
    title: 'See where it goes',
    body: 'A clear breakdown shows what you spend on, and how much.',
  ),
  OnboardingSlide(
    art: OnboardingArt.budget,
    title: 'A budget that keeps up',
    body: 'Set a monthly limit and watch the meter fill as you spend.',
  ),
  OnboardingSlide(
    art: OnboardingArt.trends,
    title: 'Spot your trends',
    body: 'Compare what comes in and goes out, month by month.',
  ),
  OnboardingSlide(
    art: OnboardingArt.sync,
    title: 'Safe in your account',
    body: 'Everything syncs to your account, so it\'s there on any device.',
  ),
];
