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
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/reveal.dart';
import '../../core/widgets/shake.dart';
import 'otp_screen.dart';
import 'widgets/login_hero.dart';

/// Step 1: enter the mobile number.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phone = TextEditingController();
  final _phoneFocus = FocusNode();
  final _shake = GlobalKey<ShakeState>();
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..forward();
  late final TapGestureRecognizer _passwordTap = TapGestureRecognizer()
    ..onTap = () => _comingSoon('ورود با رمز عبور به‌زودی اضافه می‌شود.');

  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _phoneFocus.dispose();
    _intro.dispose();
    _passwordTap.dispose();
    super.dispose();
  }

  void _comingSoon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final phone = normalizeIranMobile(_phone.text);
    if (phone == null) {
      HapticFeedback.mediumImpact();
      setState(
        () => _error =
            'شماره موبایل معتبر نیست. مثال: ${toPersianDigits('09121234567')}',
      );
      _shake.currentState?.shake();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _loading = true;
    });

    // Simulated "send code" request.
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    await Navigator.of(context)
        .push(AppRoutes.sharedAxis(OtpScreen(phone: phone)));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayOnPrimary,
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
                    Column(
                      children: [
                        const LoginHero(),
                        const SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.authMargin,
                          ),
                          child: _buildForm(),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.s24,
                        bottom: 40 + math.max(media.padding.bottom, 24.0),
                      ),
                      child: Reveal(
                        animation: _intro,
                        begin: 0.68,
                        end: 0.95,
                        offset: const Offset(0, 14),
                        child: _buildFooter(),
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

  Widget _buildForm() {
    return Column(
      children: [
        Reveal(
          animation: _intro,
          begin: 0.36,
          end: 0.62,
          child: Text(
            'ورود به حساب کاربری',
            textAlign: TextAlign.center,
            style: AppTypography.heading1.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Reveal(
          animation: _intro,
          begin: 0.42,
          end: 0.68,
          child: Text(
            'برای شروع یادگیری حساب خود را بسازید.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: 36),
        Reveal(
          animation: _intro,
          begin: 0.5,
          end: 0.76,
          child: AppTextField(
            label: 'شماره موبایل',
            hint: 'وارد کردن شماره تماس',
            controller: _phone,
            focusNode: _phoneFocus,
            errorText: _error,
            shakeKey: _shake,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: const [DigitsInputFormatter(maxLength: 11)],
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(height: AppSpacing.s32),
        Reveal(
          animation: _intro,
          begin: 0.58,
          end: 0.84,
          child: AppButton(
            label: 'ورود',
            loading: _loading,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final base = AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondary,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'میخواهم با '),
          TextSpan(
            text: 'رمز عبور',
            recognizer: _passwordTap,
            style: base.copyWith(color: AppColors.primary900),
          ),
          const TextSpan(text: ' وارد شوم.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
