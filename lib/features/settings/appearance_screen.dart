import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/app/theme_controller.dart';
import 'package:monthly_traq/features/settings/font_size_screen.dart';

/// Everything about how the app looks, in one place: light/dark mode, the
/// color preset for each, and font size.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final cardColor = Theme.of(context).cardColor;
    // Only one theme is ever actually rendering at a time — whichever
    // brightness is currently resolved — so only that section shows a
    // checkmark. The other brightness's pick is still remembered, it just
    // isn't "active" right now.
    final effectiveBrightness = switch (themeController.mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          const Text('Mode', style: AppText.sectionTitle),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            selected: {themeController.mode},
            onSelectionChanged: (selection) =>
                themeController.setMode(selection.first),
          ),
          const SizedBox(height: 24),

          const Text('Light theme', style: AppText.sectionTitle),
          const SizedBox(height: 12),
          _ThemeGrid(
            presets: kLightThemePresets,
            selectedId: themeController.lightPresetId,
            showSelection: effectiveBrightness == Brightness.light,
            onSelect: (id) {
              themeController.setLightPreset(id);
              themeController.setMode(ThemeMode.light);
            },
          ),
          const SizedBox(height: 24),

          const Text('Dark theme', style: AppText.sectionTitle),
          const SizedBox(height: 12),
          _ThemeGrid(
            presets: kDarkThemePresets,
            selectedId: themeController.darkPresetId,
            showSelection: effectiveBrightness == Brightness.dark,
            onSelect: (id) {
              themeController.setDarkPreset(id);
              themeController.setMode(ThemeMode.dark);
            },
          ),
          const SizedBox(height: 24),

          Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.format_size),
              title: const Text('Font size'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FontSizeScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  final List<AppThemePreset> presets;
  final String selectedId;
  final bool showSelection;
  final ValueChanged<String> onSelect;

  const _ThemeGrid({
    required this.presets,
    required this.selectedId,
    required this.showSelection,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.5,
      children: [
        for (final preset in presets)
          _ThemeCard(
            preset: preset,
            isSelected: showSelection && preset.id == selectedId,
            onTap: () => onSelect(preset.id),
          ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(preset.primary);
    final swatchLight = hsl
        .withLightness((hsl.lightness + 0.16).clamp(0.0, 1.0))
        .toColor();
    final swatchDark = hsl
        .withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0))
        .toColor();
    // Each card always previews its own preset's surface/text colors, not
    // whatever theme happens to be live right now — otherwise switching to
    // dark makes the light-preset cards render with a dark (and illegible)
    // label area.
    final cardColor = preset.surface;
    final labelColor = preset.brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final borderRadius = BorderRadius.circular(16);

    return Material(
      color: cardColor,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: isSelected
                ? Border.all(color: preset.primary, width: 3)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [swatchLight, swatchDark],
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.check, size: 14, color: swatchDark),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  preset.name,
                  textAlign: TextAlign.center,
                  style: AppText.labelStrong.copyWith(color: labelColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
