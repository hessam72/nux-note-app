import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';
import 'shake.dart';

/// Labelled text field: 1px border (`radius/small`), animated focus ring, error
/// text and a shake that can be triggered from outside via [shakeKey].
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.focusNode,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.shakeKey,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final GlobalKey<ShakeState>? shakeKey;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _ownFocusNode = FocusNode();
  FocusNode get _focusNode => widget.focusNode ?? _ownFocusNode;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _ownFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final focused = _focusNode.hasFocus;
    final borderColor = hasError
        ? AppColors.error
        : focused
        ? AppColors.primary
        : AppColors.inputBorder;

    Widget field = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(
          color: borderColor,
          width: focused || hasError ? 1.6 : 1,
        ),
        boxShadow: [
          if (focused && !hasError)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.14),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autofillHints: widget.autofillHints,
        cursorColor: AppColors.primary,
        style: AppTypography.bodyLarge,
        decoration: InputDecoration.collapsed(
          hintText: widget.hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.inputHint,
          ),
        ),
      ),
    );

    if (widget.shakeKey != null) {
      field = Shake(key: widget.shakeKey, child: field);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: focused && !hasError
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
          child: Text(widget.label),
        ),
        const SizedBox(height: AppSpacing.s8 - 0.5),
        field,
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s8),
                  child: Text(
                    widget.errorText!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
