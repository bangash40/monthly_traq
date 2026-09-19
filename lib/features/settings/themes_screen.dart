import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/app/theme_controller.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
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
      appBar: AppBar(title: const Text('Themes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          const Text(
            'Light theme',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _ThemeGrid(
            presets: kLightThemePresets,
            selectedId: themeController.lightPresetId,
            showSelection: effectiveBrightness == Brightness.light,
            onSelect: themeController.setLightPreset,
          ),
          const SizedBox(height: 24),

          const Text(
            'Dark theme',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _ThemeGrid(
            presets: kDarkThemePresets,
            selectedId: themeController.darkPresetId,
            showSelection: effectiveBrightness == Brightness.dark,
            onSelect: themeController.setDarkPreset,
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
    final cardColor = Theme.of(context).cardColor;
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
