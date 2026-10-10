import 'package:flutter/material.dart';
import 'package:monthly_traq/app/launch_intro.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/monthly_total.dart';
import 'package:monthly_traq/models/onboarding_slide.dart';
import 'package:monthly_traq/services/cycle_stats.dart';
import 'package:monthly_traq/widgets/charts.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

class OnboardingScreen extends StatefulWidget {
  /// Called when onboarding ends: [signUp] is true for Continue/Skip (a new
  /// user), false for "Already have an account? Log in".
  final void Function({required bool signUp}) onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == onboardingSlides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      widget.onDone(signUp: true);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    LaunchIntro.markReady();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: context.l10n.onboardingStep(
                      _index + 1,
                      onboardingSlides.length,
                    ),
                    child: Row(
                      children: [
                        for (var i = 0; i < onboardingSlides.length; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 5,
                              decoration: BoxDecoration(
                                color: i <= _index ? c.accent : c.surfaceHigh,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => widget.onDone(signUp: true),
                  style: TextButton.styleFrom(foregroundColor: c.muted),
                  child: Text(context.l10n.skip),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: onboardingSlides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) =>
                  _SlideView(slide: onboardingSlides[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _isLast
                            ? context.l10n.getStarted
                            : context.l10n.continueButton,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.alreadyHaveAccount,
                        style: AppText.body.copyWith(
                          fontSize: 16,
                          color: c.muted,
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onDone(signUp: false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        child: Text(
                          context.l10n.logIn,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final OnboardingSlide slide;

  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(28),
              child: ExcludeSemantics(child: _Art(slide.art)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            slide.title(context.l10n),
            style: AppText.titleLarge.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 10),
          Text(
            slide.body(context.l10n),
            style: AppText.body.copyWith(
              fontSize: 18,
              height: 1.4,
              color: c.muted,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

/// The illustration categories' names in the current language.
String _artName(AppLocalizations l10n, CategoryModel category) =>
    switch (category.id) {
      'food' => l10n.sampleFood,
      'shopping' => l10n.sampleShopping,
      'fun' => l10n.sampleEntertainment,
      'transport' => l10n.sampleTransport,
      _ => category.name,
    };

/// A small, real-looking piece of the app for each slide.
class _Art extends StatelessWidget {
  final OnboardingArt art;

  const _Art(this.art);

  static const _food = CategoryModel(
    id: 'food',
    name: 'Food',
    icon: Icons.restaurant,
    color: Color(0xFFEB6834),
  );
  static const _shopping = CategoryModel(
    id: 'shopping',
    name: 'Shopping',
    icon: Icons.shopping_bag,
    color: Color(0xFF2A78D6),
  );
  static const _fun = CategoryModel(
    id: 'fun',
    name: 'Entertainment',
    icon: Icons.movie,
    color: Color(0xFFEDA100),
  );
  static const _transport = CategoryModel(
    id: 'transport',
    name: 'Transport',
    icon: Icons.directions_bus,
    color: Color(0xFF9B4DCA),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final card = BoxDecoration(
      color: c.surface,
      borderRadius: BorderRadius.circular(AppRadius.largeCard),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A141726),
          blurRadius: 30,
          offset: Offset(0, 12),
        ),
      ],
    );

    Widget row(
      IconData icon,
      Color color,
      String name,
      String amount, {
      bool income = false,
    }) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconTile(icon: icon, color: color, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: AppText.rowTitle.copyWith(fontSize: 16)),
          ),
          Text(
            amount,
            style: AppText.amount.copyWith(
              fontSize: 16,
              color: income ? c.income : c.ink,
            ),
          ),
        ],
      ),
    );

    switch (art) {
      case OnboardingArt.transactions:
        return Container(
          decoration: card,
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row(
                Icons.restaurant,
                AppPalette.categorical[1],
                context.l10n.sampleGroceries,
                '${kMinus}3,450',
              ),
              const Divider(height: 1),
              row(
                Icons.work,
                const Color(0xFF16A05E),
                context.l10n.sampleSalary,
                '+120,000',
                income: true,
              ),
              const Divider(height: 1),
              row(
                Icons.directions_bus,
                AppPalette.categorical[0],
                context.l10n.sampleBusPass,
                '${kMinus}850',
              ),
            ],
          ),
        );
      case OnboardingArt.breakdown:
        return Container(
          decoration: card,
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CategoryDonut(
                size: 120,
                totals: const [
                  CategoryTotal(_shopping, 12400, 1),
                  CategoryTotal(_food, 9850, 1),
                  CategoryTotal(_fun, 5200, 1),
                  CategoryTotal(_transport, 4300, 1),
                ],
                center: const SizedBox.shrink(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (cat, pct) in [
                      (_shopping, 39),
                      (_food, 31),
                      (_fun, 16),
                      (_transport, 14),
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: cat.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _artName(context.l10n, cat),
                                style: AppText.label.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: AppText.tabular(
                                AppText.label.copyWith(color: c.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      case OnboardingArt.budget:
        return Container(
          decoration: card,
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.monthlyBudget, style: AppText.section),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Rs. 21,400',
                      style: AppText.amountLarge,
                    ),
                    TextSpan(
                      text: '  ${context.l10n.sampleLeft}',
                      style: AppText.label.copyWith(
                        fontSize: 15,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: 0.64,
                  minHeight: 10,
                  color: c.accent,
                  backgroundColor: c.surfaceHigh,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    context.l10n.percentUsed(64),
                    style: AppText.caption.copyWith(
                      fontSize: 13,
                      color: c.muted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    context.l10n.daysLeft(4),
                    style: AppText.caption.copyWith(
                      fontSize: 13,
                      color: c.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case OnboardingArt.trends:
        final now = DateTime.now();
        const values = [
          (110, 48),
          (108, 58),
          (112, 44),
          (111, 67),
          (118, 52),
          (118, 36),
        ];
        return Container(
          decoration: card,
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          child: MonthlyTrendChart(
            months: [
              for (final (i, v) in values.indexed)
                MonthlyTotal(
                  month: DateTime(now.year, now.month - 5 + i),
                  income: v.$1 * 1000.0,
                  expense: v.$2 * 1000.0,
                ),
            ],
          ),
        );
      case OnboardingArt.sync:
        return Container(
          decoration: card,
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: c.tint(c.incomeFill),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_done, color: c.income, size: 38),
              ),
              const SizedBox(height: 14),
              Text(context.l10n.sampleBackedUp, style: AppText.section),
              Text(
                context.l10n.sampleJustNow,
                style: AppText.label.copyWith(color: c.muted),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final icon in [
                    Icons.smartphone,
                    Icons.tablet_android,
                    Icons.laptop,
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconTile(icon: icon, color: c.accent, size: 44),
                    ),
                ],
              ),
            ],
          ),
        );
    }
  }
}
