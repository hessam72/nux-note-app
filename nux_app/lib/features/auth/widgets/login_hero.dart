import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design/app_colors.dart';

/// Design-space size of the hero (logical pixels on the 390pt-wide mock-up).
const _kDesignWidth = 390.0;
const _kDesignHeight = 290.0;

/// The blue header of the login screen: character, avatar bubble, leaf,
/// sparkles and the white wavy sheet.
///
/// Everything is laid out in the 390×290 design space and scaled to the screen
/// width, so the composition looks the same on every phone.
class LoginHero extends StatefulWidget {
  const LoginHero({super.key});

  /// Height the hero takes for a given screen [width].
  static double heightFor(double width) =>
      width * _kDesignHeight / _kDesignWidth;

  @override
  State<LoginHero> createState() => _LoginHeroState();
}

class _LoginHeroState extends State<LoginHero> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  // Static pieces are built once and re-used while the animations run.
  final Widget _leaf = SvgPicture.asset(
    'assets/svg/blue_leaf.svg',
    width: 90,
    height: 90,
  );
  final Widget _avatar = SvgPicture.asset(
    'assets/svg/yellow_avatar.svg',
    width: 93,
    height: 103,
  );
  final Widget _lady = Image.asset(
    'assets/images/lady.webp',
    width: 261.802,
    height: 280.718,
    fit: BoxFit.fill,
    filterQuality: FilterQuality.high,
  );

  @override
  void initState() {
    super.initState();
    _intro.forward();
    _ambient.repeat();
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  double _step(double begin, double end, [Curve curve = Curves.easeOutCubic]) =>
      Interval(begin, math.min(end, 1.0), curve: curve).transform(_intro.value);

  /// 0…1 pulse that loops with the ambient controller.
  double _pulse(double speed, double phase) =>
      0.5 + 0.5 * math.sin(2 * math.pi * (_ambient.value * speed + phase));

  Widget _sparkle({
    required double cx,
    required double cy,
    required double size,
    required Color color,
    required double begin,
    required double phase,
  }) {
    final appear = _step(begin, begin + 0.28, Curves.easeOutBack);
    final pulse = _pulse(3, phase);
    final scale = appear * (0.78 + 0.32 * pulse);
    return Positioned(
      left: cx - size / 2,
      top: cy - size / 2,
      width: size,
      height: size,
      child: Opacity(
        opacity: (appear * (0.72 + 0.28 * pulse)).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: SvgPicture.asset(
            'assets/svg/sparkle.svg',
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _ring({
    required double cx,
    required double cy,
    required double size,
    required Color color,
    required double stroke,
    required double begin,
    required double phase,
  }) {
    final appear = _step(begin, begin + 0.26, Curves.easeOutBack);
    final float = math.sin(2 * math.pi * (_ambient.value * 2 + phase)) * 3;
    return Positioned(
      left: cx - size / 2,
      top: cy - size / 2 + float,
      width: size,
      height: size,
      child: Opacity(
        opacity: appear.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: appear,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: stroke),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _kDesignWidth / _kDesignHeight,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: _kDesignWidth,
          height: _kDesignHeight,
          child: ClipRect(
            child: ColoredBox(
              color: AppColors.primary,
              child: AnimatedBuilder(
                animation: Listenable.merge([_intro, _ambient]),
                builder: (context, _) => _buildScene(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScene() {
    // Leaf + soft circle: pops from the base of the stem, then sways.
    final leafIn = _step(0.08, 0.5, Curves.easeOutBack);
    final sway = math.sin(2 * math.pi * _ambient.value) * 0.035;

    // Character: slides in from the right edge.
    final ladyIn = _step(0.0, 0.55);
    final ladyFade = _step(0.0, 0.35, Curves.easeOut);

    // Avatar bubble: springs up from its tail.
    final avatarIn = _step(0.28, 0.68, Curves.easeOutBack);
    final bob = math.sin(2 * math.pi * _ambient.value * 2 + 1) * 2.2;

    // White wavy sheet rises from the bottom of the hero.
    final waveIn = 0.14 + 0.86 * _step(0.0, 0.62);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          left: 42.5,
          top: 137,
          width: 90,
          height: 90,
          child: Transform.scale(
            scale: leafIn,
            alignment: const Alignment(0.13, 0.53),
            child: Transform.rotate(
              angle: sway,
              alignment: const Alignment(0.13, 0.53),
              child: _leaf,
            ),
          ),
        ),
        Positioned(
          left: 134,
          top: 18,
          width: 261.802,
          height: 280.718,
          child: Opacity(
            opacity: ladyFade,
            child: Transform.translate(
              offset: Offset((1 - ladyIn) * 90, (1 - ladyIn) * 14),
              child: _lady,
            ),
          ),
        ),
        Positioned.fill(
          child: Transform(
            transform: Matrix4.diagonal3Values(1, waveIn, 1),
            alignment: Alignment.bottomCenter,
            child: const CustomPaint(painter: _WavePainter()),
          ),
        ),
        _sparkle(
          cx: 153.5,
          cy: 68.5,
          size: 10,
          color: AppColors.illustrationBlue,
          begin: 0.55,
          phase: 0.1,
        ),
        _sparkle(
          cx: 138,
          cy: 127,
          size: 17,
          color: AppColors.illustrationYellowSoft,
          begin: 0.62,
          phase: 0.45,
        ),
        _sparkle(
          cx: 40,
          cy: 196,
          size: 17,
          color: AppColors.illustrationBlue,
          begin: 0.68,
          phase: 0.7,
        ),
        _sparkle(
          cx: 63,
          cy: 216.5,
          size: 9,
          color: AppColors.illustrationYellowSoft,
          begin: 0.74,
          phase: 0.25,
        ),
        _ring(
          cx: 76.5,
          cy: 122,
          size: 19,
          color: AppColors.illustrationYellowSoft,
          stroke: 1.5,
          begin: 0.58,
          phase: 0.0,
        ),
        _ring(
          cx: 82.5,
          cy: 234,
          size: 11,
          color: AppColors.illustrationBlue,
          stroke: 1,
          begin: 0.66,
          phase: 0.5,
        ),
        Positioned(
          left: 86,
          top: 158,
          width: 93,
          height: 103,
          child: Transform.translate(
            offset: Offset(0, bob * avatarIn),
            child: Transform.scale(
              scale: avatarIn,
              alignment: const Alignment(-0.7, 0.9),
              child: _avatar,
            ),
          ),
        ),
      ],
    );
  }
}

/// White sheet with a wavy top edge (two soft humps), traced from the mock-up.
class _WavePainter extends CustomPainter {
  const _WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _kDesignWidth;
    final sy = size.height / _kDesignHeight;
    final path = Path()
      ..moveTo(0, 288 * sy)
      ..cubicTo(8 * sx, 250 * sy, 35 * sx, 237 * sy, 75 * sx, 237 * sy)
      ..cubicTo(120 * sx, 237 * sy, 150 * sx, 258 * sy, 195 * sx, 258 * sy)
      ..cubicTo(240 * sx, 258 * sy, 270 * sx, 237 * sy, 315 * sx, 237 * sy)
      ..cubicTo(355 * sx, 237 * sy, 382 * sx, 250 * sy, 390 * sx, 288 * sy)
      ..lineTo(size.width, size.height + 2)
      ..lineTo(0, size.height + 2)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => false;
}
