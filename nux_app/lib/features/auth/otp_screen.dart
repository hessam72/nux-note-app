import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/app_typography.dart';
import '../../core/routing/app_routes.dart';
import '../../core/utils/persian_digits.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/reveal.dart';
import '../../core/widgets/shake.dart';
import '../home/home_screen.dart';
import 'widgets/otp_field.dart';
import 'widgets/otp_illustration.dart';

const _kCodeLength = 4;
const _kResendSeconds = 20;

/// Step 2: enter the 4-digit code that was "sent" to [phone].
///
/// There is no backend yet, so any 4-digit code is accepted.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  final _shake = GlobalKey<ShakeState>();
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();
  late final TapGestureRecognizer _changeNumberTap = TapGestureRecognizer()
    ..onTap = _changeNumber;
  late final TapGestureRecognizer _resendTap = TapGestureRecognizer()
    ..onTap = _resend;
  late final TapGestureRecognizer _supportTap = TapGestureRecognizer()
    ..onTap = () => _snack('بخش پشتیبانی به‌زودی اضافه می‌شود.');

  Timer? _timer;
  int _secondsLeft = _kResendSeconds;
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Open the keyboard once the page transition is done.
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _codeFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _codeFocus.dispose();
    _intro.dispose();
    _changeNumberTap.dispose();
    _resendTap.dispose();
    _supportTap.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _kResendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft = (_secondsLeft - 1).clamp(0, 99));
      if (_secondsLeft == 0) timer.cancel();
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _changeNumber() => Navigator.of(context).maybePop();

  void _resend() {
    if (_secondsLeft > 0) return;
    HapticFeedback.selectionClick();
    _code.clear();
    setState(() => _error = false);
    _startTimer();
    _codeFocus.requestFocus();
    _snack('کد جدید ارسال شد.');
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (_code.text.length < _kCodeLength) {
      HapticFeedback.mediumImpact();
      setState(() => _error = true);
      _shake.currentState?.shake();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    // Simulated "verify code" request.
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      AppRoutes.fadeThrough(HomeScreen(phone: widget.phone)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayOnLight,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 140),
                      child: _buildContent(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.s24,
                        bottom: 40 + math.max(media.padding.bottom, 24.0),
                      ),
                      child: Reveal(
                        animation: _intro,
                        begin: 0.7,
                        end: 0.95,
                        offset: const Offset(0, 14),
                        child: Text.rich(
                          TextSpan(
                            text: 'تماس با پشتیبانی',
                            recognizer: _supportTap,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.support,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.authMargin),
      child: Column(
        children: [
          const OtpIllustration(delay: Duration(milliseconds: 180)),
          const SizedBox(height: 82),
          Reveal(
            animation: _intro,
            begin: 0.3,
            end: 0.58,
            child: Text(
              'کد ارسال شده به شماره\n${toPersianDigits(widget.phone)} را وارد نمایید.',
              textAlign: TextAlign.center,
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Reveal(
            animation: _intro,
            begin: 0.36,
            end: 0.64,
            offset: const Offset(0, 14),
            child: Text.rich(
              TextSpan(
                text: 'تغییر شماره تلفن و یا ایمیل',
                recognizer: _changeNumberTap,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          OtpField(
            controller: _code,
            focusNode: _codeFocus,
            length: _kCodeLength,
            shakeKey: _shake,
            entrance: _intro,
            entranceBegin: 0.42,
            hasError: _error,
            onChanged: (_) {
              if (_error) setState(() => _error = false);
            },
          ),
          const SizedBox(height: AppSpacing.s16),
          Reveal(
            animation: _intro,
            begin: 0.58,
            end: 0.84,
            child: AppButton(
              label: 'ارسال',
              loading: _loading,
              onPressed: _submit,
            ),
          ),
          const SizedBox(height: 16),
          Reveal(
            animation: _intro,
            begin: 0.64,
            end: 0.9,
            offset: const Offset(0, 14),
            child: _buildResend(),
          ),
        ],
      ),
    );
  }

  Widget _buildResend() {
    final style = AppTypography.labelSmall.copyWith(
      color: AppColors.textSecondary,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: _secondsLeft > 0
          ? Row(
              key: const ValueKey('countdown'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ارسال مجدد کد بعد از ', style: style),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.6),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    toPersianDigits(_secondsLeft),
                    key: ValueKey(_secondsLeft),
                    style: style.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(' ثانیه', style: style),
              ],
            )
          : Text.rich(
              key: const ValueKey('resend'),
              TextSpan(
                text: 'ارسال مجدد کد',
                recognizer: _resendTap,
                style: style.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
    );
  }
}
