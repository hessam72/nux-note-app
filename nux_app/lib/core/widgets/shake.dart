import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Wraps [child] and shakes it horizontally when [ShakeState.shake] is called.
class Shake extends StatefulWidget {
  const Shake({super.key, required this.child, this.distance = 9});

  final Widget child;
  final double distance;

  @override
  State<Shake> createState() => ShakeState();
}

class ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );

  Future<void> shake() async {
    if (!mounted) return;
    await _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        // Damped sine: 3 swings that fade out.
        final dx = math.sin(t * math.pi * 6) * (1 - t) * widget.distance;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}
