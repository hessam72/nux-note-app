import 'package:flutter/material.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/utils/persian_digits.dart';
import '../../../core/widgets/reveal.dart';
import '../../../core/widgets/shake.dart';

/// One-time-code input: [length] square boxes (48×48, 12 apart, `radius/small`)
/// driven by a single invisible text field, so paste / SMS auto-fill work.
class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.length = 4,
    this.onChanged,
    this.onCompleted,
    this.shakeKey,
    this.entrance,
    this.entranceBegin = 0,
    this.hasError = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final GlobalKey<ShakeState>? shakeKey;
  final bool hasError;

  /// Optional parent animation used to pop the boxes in one after another.
  final Animation<double>? entrance;
  final double entranceBegin;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
    widget.focusNode.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    widget.focusNode.removeListener(_onUpdate);
    super.dispose();
  }

  String _lastText = '';

  void _onUpdate() {
    final text = widget.controller.text;
    if (text != _lastText) {
      _lastText = text;
      widget.onChanged?.call(text);
      if (text.length == widget.length) widget.onCompleted?.call(text);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final focused = widget.focusNode.hasFocus;
    final activeIndex = text.length.clamp(0, widget.length - 1);

    final boxes = <Widget>[];
    for (var i = 0; i < widget.length; i++) {
      Widget box = _OtpBox(
        digit: i < text.length ? text[i] : null,
        active: focused && i == activeIndex,
        error: widget.hasError,
      );
      if (widget.entrance != null) {
        final begin = widget.entranceBegin + i * 0.04;
        box = Reveal(
          animation: widget.entrance!,
          begin: begin,
          end: begin + 0.22,
          offset: const Offset(0, 18),
          curve: Curves.easeOutBack,
          child: box,
        );
      }
      boxes.add(box);
    }

    Widget row = SizedBox(
      width: widget.length * 48.0 + (widget.length - 1) * AppSpacing.s12,
      height: 48,
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < boxes.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.s12),
                boxes[i],
              ],
            ],
          ),
          // Invisible field that actually receives the typing.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [
                  DigitsInputFormatter(maxLength: widget.length),
                ],
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration.collapsed(hintText: ''),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.shakeKey != null) {
      row = Shake(key: widget.shakeKey, child: row);
    }
    return row;
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.active,
    required this.error,
  });

  final String? digit;
  final bool active;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final borderColor = error
        ? AppColors.error
        : active
        ? AppColors.primary
        : AppColors.inputBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: borderColor, width: active || error ? 2 : 1),
        boxShadow: [
          if (active && !error)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.16),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: digit != null
            ? Text(
                toPersianDigits(digit!),
                key: ValueKey(digit),
                style: AppTypography.heading1.copyWith(
                  fontSize: 24,
                  color: AppColors.gray950,
                ),
              )
            : active
            ? const _BlinkingCaret(key: ValueKey('caret'))
            : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }
}

class _BlinkingCaret extends StatefulWidget {
  const _BlinkingCaret({super.key});

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      child: Container(
        width: 2,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
