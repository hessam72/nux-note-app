import 'package:flutter/material.dart';

/// Fades + slides [child] in while [animation] runs between [begin] and [end]
/// (both fractions of the parent animation). Used to stagger screen content.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.offset = const Offset(0, 22),
    this.curve = Curves.easeOutCubic,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Offset offset;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final interval = Interval(begin, end, curve: curve);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = interval.transform(animation.value);
        if (t >= 1) return child!;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(offset.dx * (1 - t), offset.dy * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}
