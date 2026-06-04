import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';

/// How the [YtuLogo] renders.
enum YtuLogoMode {
  /// Filled 10-point star only — for small / inline logo use.
  mark,

  /// Star centered inside a circular seal (navy ring + gold inner ring + gold
  /// star), evoking the official YTU emblem — for hero / branded surfaces.
  badge,
}

/// The YTU emblem motif rendered as a 10-pointed star (decagram) with a custom
/// painter. Fully scalable and asset-free.
///
/// ```dart
/// const YtuLogo(size: 88, mode: YtuLogoMode.badge, withGlow: true)
/// ```
class YtuLogo extends StatelessWidget {
  const YtuLogo({
    super.key,
    this.size = 72,
    this.mode = YtuLogoMode.mark,
    this.starColor = AppColors.secondary,
    this.ringColor = AppColors.primary,
    this.backgroundColor,
    this.withGlow = false,
  });

  /// Width & height of the (square) logo, in logical pixels.
  final double size;
  final YtuLogoMode mode;

  /// Star fill color (defaults to YTU gold).
  final Color starColor;

  /// Seal ring color in [YtuLogoMode.badge] (defaults to YTU navy).
  final Color ringColor;

  /// Optional filled background circle drawn behind everything.
  final Color? backgroundColor;

  /// Draws a soft radial blur halo behind the star (splash / login hero).
  final bool withGlow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size.square(size),
        painter: _YtuLogoPainter(
          mode: mode,
          starColor: starColor,
          ringColor: ringColor,
          backgroundColor: backgroundColor,
          withGlow: withGlow,
        ),
      ),
    );
  }
}

class _YtuLogoPainter extends CustomPainter {
  const _YtuLogoPainter({
    required this.mode,
    required this.starColor,
    required this.ringColor,
    required this.backgroundColor,
    required this.withGlow,
  });

  final YtuLogoMode mode;
  final Color starColor;
  final Color ringColor;
  final Color? backgroundColor;
  final bool withGlow;

  /// Number of star points. 10 points => 20 alternating vertices (decagram).
  static const int _points = 10;

  /// Inner/outer radius ratio for a crisp 10-point star.
  static const double _innerRatio = 0.62;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double r = size.shortestSide / 2;

    if (backgroundColor != null) {
      canvas.drawCircle(center, r, Paint()..color = backgroundColor!);
    }

    final double starOuter;
    if (mode == YtuLogoMode.badge) {
      // Outer navy ring.
      final double ringStroke = r * 0.10;
      canvas.drawCircle(
        center,
        r - ringStroke / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringStroke
          ..color = ringColor
          ..isAntiAlias = true,
      );

      // Navy seal interior so the gold star reads with contrast.
      canvas.drawCircle(
        center,
        r - ringStroke,
        Paint()..color = ringColor,
      );

      // Thin gold inner ring.
      canvas.drawCircle(
        center,
        r * 0.78,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.035
          ..color = starColor
          ..isAntiAlias = true,
      );

      starOuter = r * 0.60;
    } else {
      starOuter = r;
    }

    final Path star = _buildStar(center, starOuter, starOuter * _innerRatio);

    if (withGlow) {
      canvas.drawPath(
        star,
        Paint()
          ..color = starColor.withValues(alpha: 0.45)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, starOuter * 0.18),
      );
    }

    canvas.drawPath(
      star,
      Paint()
        ..color = starColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  Path _buildStar(Offset c, double outer, double inner) {
    final Path path = Path();
    const int total = _points * 2;
    const double step = math.pi / _points;
    for (int i = 0; i < total; i++) {
      final double radius = i.isEven ? outer : inner;
      final double angle = -math.pi / 2 + step * i;
      final Offset p = Offset(
        c.dx + radius * math.cos(angle),
        c.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_YtuLogoPainter old) =>
      old.mode != mode ||
      old.starColor != starColor ||
      old.ringColor != ringColor ||
      old.backgroundColor != backgroundColor ||
      old.withGlow != withGlow;
}
