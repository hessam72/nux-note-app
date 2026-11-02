import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';

/// Primary button: 48 high, `radius/medium`, hugs its label.
///
/// Pressing it scales it down; when [loading] it morphs into a round spinner.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final loading = widget.loading;
    final enabled = widget.onPressed != null && !loading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeInOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeInOutCubic,
              height: 48,
              decoration: BoxDecoration(
                color: _pressed ? AppColors.primary700 : AppColors.primary,
                borderRadius: BorderRadius.circular(
                  loading ? 24 : AppRadius.medium,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: loading ? 13 : 24),
              child: Center(
                widthFactor: 1,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: loading
                      ? const SizedBox.square(
                          key: ValueKey('spinner'),
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            strokeCap: StrokeCap.round,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.label,
                          key: const ValueKey('label'),
                          maxLines: 1,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
