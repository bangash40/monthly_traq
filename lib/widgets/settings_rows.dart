import 'package:flutter/material.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// How a settings row behaves and looks.
enum SettingsRowKind {
  /// Opens something: chevron on the right.
  link,

  /// Not built yet: muted, "Soon" badge, not tappable.
  soon,

  /// Part of a future paid tier: "PRO" badge and a chevron.
  pro,

  /// An on/off switch.
  toggle,

  /// Irreversible: red icon and label.
  destructive,
}

/// A row on the Profile tab: icon tile, label, and a value, badge, switch
/// or chevron on the right.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final SettingsRowKind kind;
  final VoidCallback? onTap;
  final bool toggleValue;
  final ValueChanged<bool>? onToggle;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.kind = SettingsRowKind.link,
    this.onTap,
    this.toggleValue = false,
    this.onToggle,
  });

  const SettingsRow.soon({super.key, required this.icon, required this.label})
    : value = null,
      kind = SettingsRowKind.soon,
      onTap = null,
      toggleValue = false,
      onToggle = null;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isSoon = kind == SettingsRowKind.soon;
    final isDestructive = kind == SettingsRowKind.destructive;
    final isToggle = kind == SettingsRowKind.toggle;

    final (tileBackground, iconColor) = isSoon
        ? (c.surfaceHigh, c.faint)
        : isDestructive
        ? (c.tint(c.spendingFill), c.spending)
        : (c.primarySoft, c.accent);

    final Widget trailing = switch (kind) {
      SettingsRowKind.soon => const TagBadge.soon(),
      SettingsRowKind.toggle => Switch(value: toggleValue, onChanged: onToggle),
      SettingsRowKind.pro => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TagBadge.pro(),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, color: c.faint),
        ],
      ),
      _ => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                value!,
                style: AppText.label.copyWith(color: c.muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: c.faint),
        ],
      ),
    };

    final row = Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isToggle ? 6 : 12,
        12,
        isToggle ? 6 : 12,
      ),
      child: Row(
        children: [
          IconTile(
            icon: icon,
            color: iconColor,
            background: tileBackground,
            size: 38,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppText.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSoon
                    ? c.muted
                    : isDestructive
                    ? c.spending
                    : c.ink,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );

    if (isSoon) {
      return Semantics(label: '$label, coming soon', child: row);
    }
    if (isToggle) {
      return InkWell(onTap: () => onToggle?.call(!toggleValue), child: row);
    }
    return InkWell(onTap: onTap, child: row);
  }
}

/// An overline heading and a card of rows.
class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const SettingsGroup({super.key, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OverlineLabel(title),
          GroupCard(children: rows),
        ],
      ),
    );
  }
}
