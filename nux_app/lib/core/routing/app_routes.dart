import 'package:flutter/material.dart';

/// Custom page transitions.
abstract final class AppRoutes {
  /// Horizontal shared-axis: the new page slides in along the reading
  /// direction (from the left in RTL) while cross-fading with the old one.
  static Route<T> sharedAxis<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 560),
      reverseTransitionDuration: const Duration(milliseconds: 440),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rtl = Directionality.of(context) == TextDirection.rtl;
        final sign = rtl ? -1.0 : 1.0;

        final enter = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final exit = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubic,
        );

        return AnimatedBuilder(
          animation: Listenable.merge([enter, exit]),
          child: child,
          builder: (context, child) {
            final width = MediaQuery.sizeOf(context).width;
            // Incoming page: slides 18% of the width, fades in.
            final inDx = (1 - enter.value) * width * 0.18 * sign;
            final inOpacity = Interval(
              0,
              0.7,
              curve: Curves.easeOut,
            ).transform(animation.value);
            // Page that is being covered: drifts away and fades out.
            final outDx = -exit.value * width * 0.12 * sign;
            final outOpacity =
                1 -
                Interval(
                  0,
                  0.6,
                  curve: Curves.easeIn,
                ).transform(secondaryAnimation.value);

            return Opacity(
              opacity: (inOpacity * outOpacity).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(inDx + outDx, 0),
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  /// Fade-through with a gentle scale: used when switching to a new "root".
  static Route<T> fadeThrough<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 700),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.15, 1, curve: Curves.easeOut),
        );
        final scale = Tween<double>(begin: 0.92, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }
}
