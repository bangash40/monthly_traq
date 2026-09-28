import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';

/// The design's basic building blocks. Every screen is assembled from these
/// so spacing, radii and colors stay consistent across themes and modes.

/// A surface card: white with a hairline and soft shadow in light mode, a
/// lifted surface with a hairline in dark mode.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadius.card,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final borderRadius = BorderRadius.circular(radius);
    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: borderRadius,
        border: Border.all(color: c.hairline),
        boxShadow: c.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          type: MaterialType.transparency,
          child: onTap == null
              ? content
              : InkWell(onTap: onTap, child: content),
        ),
      ),
    );
  }
}

/// A card of rows separated by hairlines, e.g. a day's transactions or a
/// settings group.
class GroupCard extends StatelessWidget {
  final List<Widget> children;

  const GroupCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const Divider(height: 1),
            child,
          ],
        ],
      ),
    );
  }
}

/// An icon on a rounded square: a soft tint of [color] behind an icon in
/// [color], or [solid] color with a white icon.
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool solid;
  final Color? background;

  const IconTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
    this.solid = false,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? (solid ? color : c.tint(color)),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, size: size * 0.5, color: solid ? Colors.white : color),
    );
  }
}

enum BadgeTone { neutral, warning, income, spending }

/// A small pill label: "Soon", "PRO", "↓ 12% vs Aug".
class TagBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;
  final IconData? icon;

  const TagBadge(
    this.label, {
    super.key,
    this.tone = BadgeTone.neutral,
    this.icon,
  });

  const TagBadge.soon({super.key})
    : label = 'Soon',
      tone = BadgeTone.neutral,
      icon = null;

  const TagBadge.pro({super.key})
    : label = 'PRO',
      tone = BadgeTone.warning,
      icon = null;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (background, foreground) = switch (tone) {
      BadgeTone.neutral => (c.surfaceHigh, c.muted),
      BadgeTone.warning => (c.tint(c.warningFill), c.warning),
      BadgeTone.income => (c.tint(c.incomeFill), c.income),
      BadgeTone.spending => (c.tint(c.spendingFill), c.spending),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: AppText.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Recent ........ See all".
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader(this.title, {super.key, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppText.section.copyWith(fontSize: 19)),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// A tracked-out uppercase label above a group ("BUDGET").
class OverlineLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const OverlineLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(4, 0, 4, 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: AppText.overline.copyWith(color: context.colors.muted),
      ),
    );
  }
}

/// The round back button used on sub-pages instead of an app bar.
class BackCircleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  const BackCircleButton({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_back,
    this.tooltip = 'Back',
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surfaceHigh,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.maybePop(context),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: c.ink, size: 24),
          ),
        ),
      ),
    );
  }
}

/// A sub-page: back button and title in the page itself (no app bar), a
/// scrolling body, and an optional button pinned to the bottom.
class SubPageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottom;
  final Widget? trailing;

  const SubPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                const BackCircleButton(),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: AppText.screenTitle.copyWith(fontSize: 24),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Expanded(child: body),
          if (bottom != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: bottom,
              ),
            ),
        ],
      ),
    );
  }
}

class AppSegment<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppSegment(this.value, this.label, {this.icon});
}

/// The design's segmented control: a tinted track with a raised thumb on
/// the selected option.
class AppSegmented<T> extends StatelessWidget {
  final List<AppSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;

  const AppSegmented({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final thumb = c.isDark
        ? Color.alphaBlend(const Color(0x24FFFFFF), c.surface)
        : c.surface;

    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.button + 2),
      ),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: Semantics(
                button: true,
                selected: segment.value == value,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(segment.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: segment.value == value ? thumb : null,
                      borderRadius: BorderRadius.circular(AppRadius.button - 2),
                      boxShadow: segment.value == value && !c.isDark
                          ? const [
                              BoxShadow(
                                color: Color(0x14141726),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (segment.icon != null) ...[
                          Icon(
                            segment.icon,
                            size: 18,
                            color: segment.value == value ? c.ink : c.muted,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            segment.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.rowTitle.copyWith(
                              fontWeight: segment.value == value
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: segment.value == value ? c.ink : c.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A bold label above a form field, with an optional link on the right
/// ("Password ........ Forgot?").
class LabeledField extends StatelessWidget {
  final String label;
  final Widget field;
  final Widget? trailing;

  const LabeledField({
    super.key,
    required this.label,
    required this.field,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 28,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppText.rowTitle.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}

/// "AM" from "Alex Morgan"; falls back to the email's first letter.
String initialsFor(String? name, String? email) {
  final words = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isNotEmpty) {
    return words.take(2).map((w) => w[0]).join().toUpperCase();
  }
  final fallback = (email ?? '').trim();
  return fallback.isEmpty ? '?' : fallback[0].toUpperCase();
}

/// The profile photo, or initials when there's none. [filled] uses the
/// brand color (profile screens); otherwise a soft tint (Home header).
class ProfileAvatar extends StatelessWidget {
  final String? photoBase64;
  final String initials;
  final double size;
  final bool filled;

  const ProfileAvatar({
    super.key,
    required this.photoBase64,
    required this.initials,
    this.size = 48,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final photo = photoBase64;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: filled ? c.primary : c.primarySoft,
      backgroundImage: photo != null ? MemoryImage(base64Decode(photo)) : null,
      child: photo == null
          ? Text(
              initials,
              style: AppText.section.copyWith(
                fontSize: size * 0.34,
                height: 1,
                color: filled ? c.onPrimary : c.accent,
              ),
            )
          : null,
    );
  }
}

/// A friendly placeholder for something with nothing in it yet, with an
/// optional next step.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Draws its own card; turn off when it already sits inside one.
  final bool card;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.card = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Icon(icon, color: c.accent, size: 30),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.section.copyWith(fontSize: 19),
        ),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(color: c.muted),
          ),
        ],
        if (actionLabel != null) ...[
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              textStyle: AppText.rowTitle.copyWith(fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
            ),
            child: Text(actionLabel!),
          ),
        ],
      ],
    );

    if (!card) {
      return Padding(padding: const EdgeInsets.all(24), child: content);
    }
    return AppCard(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: SizedBox(width: double.infinity, child: content),
    );
  }
}

/// A rounded progress bar: a [color] fill over a tinted track, sized to
/// the full width it's given.
class MeterBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const MeterBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: context.colors.surfaceHigh),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a primary button's label with a spinner while [loading].
class ButtonLabel extends StatelessWidget {
  final String text;
  final bool loading;
  final IconData? icon;

  const ButtonLabel(this.text, {super.key, this.loading = false, this.icon});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: DefaultTextStyle.of(context).style.color,
        ),
      );
    }
    if (icon == null) return Text(text);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 22), const SizedBox(width: 8), Text(text)],
    );
  }
}

/// The app mark: a wallet on the brand color (login, licenses page).
class AppLogoTile extends StatelessWidget {
  const AppLogoTile({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Icon(Icons.account_balance_wallet, color: c.onPrimary, size: 34),
    );
  }
}
