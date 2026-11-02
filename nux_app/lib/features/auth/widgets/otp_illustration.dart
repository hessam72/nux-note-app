import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Blue speech bubble with a check mark (187×123).
///
/// The bubble is `blue_tick_bubble.svg` (the original `blue_tick.svg` without
/// the check). The check is drawn in code so it can be animated: the bubble
/// pops in, then the check is "written" stroke by stroke, then the whole
/// illustration floats gently.
class OtpIllustration extends StatefulWidget {
  const OtpIllustration({super.key, this.delay = Duration.zero});

  final Duration delay;

  @override
  State<OtpIllustration> createState() => _OtpIllustrationState();
}

class _OtpIllustrationState extends State<OtpIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  final Widget _bubble = SvgPicture.asset(
    'assets/svg/blue_tick_bubble.svg',
    width: 187,
    height: 123,
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        _intro.forward();
        _float.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 187,
      height: 123,
      child: AnimatedBuilder(
        animation: Listenable.merge([_intro, _float]),
        builder: (context, _) {
          final pop = Interval(
            0,
            0.45,
            curve: Curves.easeOutBack,
          ).transform(_intro.value);
          final fade = Interval(
            0,
            0.25,
            curve: Curves.easeOut,
          ).transform(_intro.value);
          final check = Interval(
            0.42,
            0.8,
            curve: Curves.easeInOutCubic,
          ).transform(_intro.value);
          // Floats ±3dp around its resting position.
          final dy = (Curves.easeInOut.transform(_float.value) - 0.5) * -6;

          return Opacity(
            opacity: fade.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, dy),
              child: Transform.scale(
                scale: 0.55 + 0.45 * pop,
                child: Stack(
                  children: [
                    _bubble,
                    CustomPaint(
                      size: const Size(187, 123),
                      painter: _CheckPainter(progress: check),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress});

  final double progress;

  // Same geometry as the check path in blue_tick.svg.
  static final Path _check = Path()
    ..moveTo(78, 66.0001)
    ..lineTo(87.4679, 75.4652)
    ..cubicTo(89.4207, 77.4175, 92.5863, 77.4171, 94.5387, 75.4645)
    ..lineTo(117, 53);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final metrics = _check.computeMetrics().toList();
    final total = metrics.fold<double>(
      0,
      (sum, PathMetric m) => sum + m.length,
    );
    var remaining = total * math.min(progress, 1);
    for (final metric in metrics) {
      if (remaining <= 0) break;
      final length = math.min(remaining, metric.length);
      canvas.drawPath(metric.extractPath(0, length), paint);
      remaining -= length;
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
