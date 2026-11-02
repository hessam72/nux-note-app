import 'package:flutter/painting.dart';

/// Colour tokens sampled from the "Colors" page of the design system.
///
/// Both scales run 50 (lightest) → 950 (darkest).
abstract final class AppColors {
  // ── Primary (indigo) ───────────────────────────────────────────────────────
  static const primary50 = Color(0xFFEFEEFD);
  static const primary100 = Color(0xFFE0E1FD);
  static const primary200 = Color(0xFFC7C8FA);
  static const primary300 = Color(0xFFA5A7F6);
  static const primary400 = Color(0xFF8184F2);
  static const primary500 = Color(0xFF6366E9);

  /// Brand colour: buttons, links, focus rings, hero background.
  static const primary600 = Color(0xFF4649E6);
  static const primary700 = Color(0xFF383BC2);
  static const primary800 = Color(0xFF30329D);
  static const primary900 = Color(0xFF2F317E);
  static const primary950 = Color(0xFF1B1C49);

  static const primary = primary600;

  // ── Neutral (gray) ─────────────────────────────────────────────────────────
  static const gray50 = Color(0xFFF8F9F8);
  static const gray100 = Color(0xFFEDEEF2);
  static const gray200 = Color(0xFFD8D9DE);
  static const gray300 = Color(0xFFB7BAC2);
  static const gray400 = Color(0xFF8E95A0);
  static const gray500 = Color(0xFF6D727F);
  static const gray600 = Color(0xFF5C616E);
  static const gray700 = Color(0xFF5A616D);
  static const gray800 = Color(0xFF4B4E59);
  static const gray900 = Color(0xFF383A40);
  static const gray950 = Color(0xFF26272B);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const success = Color(0xFF448C47);
  static const successLight = Color(0xFFE8F4EA);
  static const error = Color(0xFFC74031);
  static const errorLight = Color(0xFFF9E8E6);
  static const warning = Color(0xFFEAB340);

  // ── Surfaces & text (semantic aliases) ─────────────────────────────────────
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF000000);
  static const textBody = gray950;

  /// Secondary text (labels, hints, countdown). Measured from the mock-ups.
  static const textSecondary = Color(0xFF737373);

  /// Tertiary text (sub-titles). Measured from the mock-ups.
  static const textTertiary = Color(0xFFA6A6A6);
  static const inputBorder = Color(0xFFB6BAC3);
  static const inputHint = Color(0xFF5B616F);

  /// "تماس با پشتیبانی" link colour used on the OTP screen mock-up.
  static const support = Color(0xFFD93025);

  // ── Illustration colours (taken from the SVG assets) ───────────────────────
  static const illustrationYellow = Color(0xFFF4B00D);
  static const illustrationYellowSoft = Color(0xFFFECF71);
  static const illustrationBlue = Color(0xFF7CB2E0);
  static const illustrationNavy = Color(0xFF1539A4);
}
