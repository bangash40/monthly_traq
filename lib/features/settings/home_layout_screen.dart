import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/home_layout.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

/// Profile → Appearance → Home screen layout: turn Home's cards on or off
/// and drag them into the order you want.
class HomeLayoutScreen extends StatelessWidget {
  const HomeLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final settings = context.watch<AppSettings>();
    final layout = settings.homeLayout;

    return SubPageScaffold(
      title: context.l10n.homeScreenLayout,
      body: ReorderableListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        buildDefaultDragHandles: false,
        header: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            context.l10n.homeLayoutHelp,
            style: AppText.body.copyWith(color: c.muted),
          ),
        ),
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 14),
            Text(
              context.l10n.balanceCardSection.toUpperCase(),
              style: AppText.overline.copyWith(color: c.muted),
            ),
            const SizedBox(height: 10),
            _SwitchCard(
              icon: Icons.visibility_outlined,
              label: context.l10n.privacyButton,
              description: context.l10n.privacyButtonAbout,
              value: settings.showPrivacyButton,
              onChanged: settings.setShowPrivacyButton,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: settings.isDefaultHome ? null : settings.resetHome,
                icon: const Icon(Icons.restart_alt),
                label: Text(context.l10n.resetToDefault),
              ),
            ),
          ],
        ),
        onReorderItem: (from, to) =>
            settings.setHomeLayout(layout.moved(from, to)),
        children: [
          for (final (index, card) in layout.order.indexed)
            _CardRow(
              key: ValueKey(card),
              index: index,
              card: card,
              visible: layout.isVisible(card),
              onChanged: layout.canHide(card)
                  ? (show) => settings.setHomeLayout(
                      layout.withVisibility(card, show),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final int index;
  final HomeCard card;
  final bool visible;

  /// Null when this is the last card showing, which can't be turned off.
  final ValueChanged<bool>? onChanged;

  const _CardRow({
    super.key,
    required this.index,
    required this.card,
    required this.visible,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _SwitchCard(
        icon: card.icon,
        label: card.label(context.l10n),
        description: card.description(context.l10n),
        value: visible,
        onChanged: onChanged,
        leading: ReorderableDragStartListener(
          index: index,
          child: Semantics(
            label: context.l10n.dragToReorder(card.label(context.l10n)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.drag_indicator, color: c.faint),
            ),
          ),
        ),
      ),
    );
  }
}

/// A card with an icon, a label and description, and an on/off switch.
class _SwitchCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// The drag handle on reorderable rows.
  final Widget? leading;

  const _SwitchCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AppCard(
      padding: EdgeInsets.fromLTRB(leading == null ? 16 : 4, 10, 12, 10),
      child: Row(
        children: [
          ?leading,
          IconTile(
            icon: icon,
            color: value ? c.accent : c.faint,
            background: value ? c.primarySoft : c.surfaceHigh,
            size: 40,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: value ? c.ink : c.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppText.label.copyWith(color: c.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
