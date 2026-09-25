import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/app/theme_controller.dart';

class FontSizeScreen extends StatelessWidget {
  const FontSizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final accent = themeAccent(context);
    final stops = kFontScaleSteps.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Font Size')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
        children: [
          Slider(
            value: themeController.fontSizeStep.toDouble(),
            min: 0,
            max: (stops - 1).toDouble(),
            divisions: stops - 1,
            activeColor: accent,
            onChanged: (value) => themeController.setFontSizeStep(value.round()),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < stops; i++)
                  Text(
                    'A',
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      fontSize: 12 + i * 4,
                      fontWeight: i == themeController.fontSizeStep
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: i == themeController.fontSizeStep ? accent : null,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'The quick brown fox jumps over the lazy dog.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
