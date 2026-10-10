import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/app/theme_controller.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

/// Mode (System / Light / Dark), theme and text size, all in one place.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final c = context.colors;
    // Previews show each theme in whichever mode is on screen right now.
    final brightness = Theme.of(context).brightness;
    final steps = kFontScaleSteps.length;

    return SubPageScaffold(
      title: context.l10n.appearance,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          OverlineLabel(context.l10n.mode),
          AppSegmented<ThemeMode>(
            value: themeController.mode,
            height: 52,
            segments: [
              AppSegment(
                ThemeMode.system,
                context.l10n.modeSystem,
                icon: Icons.brightness_auto_outlined,
              ),
              AppSegment(
                ThemeMode.light,
                context.l10n.modeLight,
                icon: Icons.light_mode_outlined,
              ),
              AppSegment(
                ThemeMode.dark,
                context.l10n.modeDark,
                icon: Icons.dark_mode_outlined,
              ),
            ],
            onChanged: themeController.setMode,
          ),
          const SizedBox(height: 28),
          OverlineLabel(context.l10n.theme),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.12,
            children: [
              for (final theme in kAppThemes)
                _ThemeCard(
                  theme: theme,
                  palette: theme.palette(brightness),
                  selected: theme.id == themeController.themeId,
                  onTap: () => themeController.setTheme(theme.id),
                ),
            ],
          ),
          const SizedBox(height: 28),
          OverlineLabel(context.l10n.textSize),
          AppCard(
            radius: AppRadius.largeCard,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'A',
                      textScaler: TextScaler.noScaling,
                      style: AppText.rowTitle.copyWith(color: c.muted),
                    ),
                    Expanded(
                      child: Slider(
                        value: themeController.fontSizeStep.toDouble(),
                        min: 0,
                        max: (steps - 1).toDouble(),
                        divisions: steps - 1,
                        label: themeController.fontSizeLabel(context.l10n),
                        semanticFormatterCallback: (value) =>
                            fontSizeStepLabel(context.l10n, value.round()),
                        onChanged: (value) =>
                            themeController.setFontSizeStep(value.round()),
                      ),
                    ),
                    Text(
                      'A',
                      textScaler: TextScaler.noScaling,
                      style: AppText.section.copyWith(
                        fontSize: 26,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.textSizePreview(context.money.format(3450)),
                  style: AppText.body.copyWith(fontSize: 16, color: c.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A miniature of the theme: its page color, a balance card in its primary
/// color, and a row on its surface.
class _ThemeCard extends StatelessWidget {
  final AppTheme theme;
  final ThemePalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final line = isDark ? const Color(0x33FFFFFF) : const Color(0x1F141726);
    final radius = BorderRadius.circular(AppRadius.card);

    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.themeCardLabel(theme.name),
      excludeSemantics: true,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? c.accent : c.hairline,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: palette.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: palette.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: palette.onPrimary.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const Spacer(),
                                if (selected)
                                  Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: palette.onPrimary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: palette.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: palette.accent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: line,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: palette.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      theme.name,
                      style: AppText.rowTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
