import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';

/// "Continue with Google" — an outlined button with the Google "G".
class GoogleSignInButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const GoogleSignInButton({
    super.key,
    this.label = 'Continue with Google',
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox.square(dimension: 22, child: _GoogleLogo()),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: AppText.button.copyWith(color: context.colors.ink),
                  ),
                ],
              ),
      ),
    );
  }
}

/// "or" between the email form and the Google button.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: AppText.rowTitle.copyWith(color: c.muted)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GoogleLogoPainter());
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = (Offset.zero & size).center;
    final radius = size.width / 2;
    const stroke = 3.4;
    final arcRect = Rect.fromCircle(
      center: center,
      radius: radius - stroke / 2,
    );

    void arc(Color color, double startDeg, double sweepDeg) {
      canvas.drawArc(
        arcRect,
        startDeg * math.pi / 180,
        sweepDeg * math.pi / 180,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
    }

    arc(const Color(0xFF4285F4), -20, 110);
    arc(const Color(0xFFEA4335), -70, 50);
    arc(const Color(0xFFFBBC05), 130, 60);
    arc(const Color(0xFF34A853), 190, 100);

    // The G's crossbar.
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - stroke / 2, radius, stroke),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
