import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/app_typography.dart';
import '../../core/routing/app_routes.dart';
import '../../core/utils/persian_digits.dart';
import '../../core/widgets/reveal.dart';
import '../auth/login_screen.dart';

/// Placeholder home page (no design yet): greets the user and lets them log
/// out.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.phone});

  final String phone;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      AppRoutes.fadeThrough(const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayOnLight,
      child: Scaffold(
        backgroundColor: AppColors.primary50,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.authMargin),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Reveal(
                    animation: _intro,
                    begin: 0,
                    end: 0.5,
                    curve: Curves.easeOutBack,
                    offset: const Offset(0, 30),
                    child: SvgPicture.asset(
                      'assets/svg/yellow_avatar.svg',
                      width: 93,
                      height: 103,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  Reveal(
                    animation: _intro,
                    begin: 0.25,
                    end: 0.65,
                    child: Text(
                      'خانه',
                      style: AppTypography.heading1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Reveal(
                    animation: _intro,
                    begin: 0.35,
                    end: 0.75,
                    child: Text(
                      'با شماره ${toPersianDigits(widget.phone)} وارد شدید.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s32),
                  Reveal(
                    animation: _intro,
                    begin: 0.5,
                    end: 0.9,
                    child: TextButton(
                      onPressed: _logout,
                      child: Text(
                        'خروج از حساب',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.error,
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
    );
  }
}
