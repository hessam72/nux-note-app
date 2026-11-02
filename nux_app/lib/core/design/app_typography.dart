import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Type scale from the "Typography" page: `fontSize / lineHeight`.
///
/// The design uses *IranYekanX FaNum*. Until its files are dropped into
/// `assets/fonts/` (see pubspec.yaml) the bundled Vazirmatn (Farsi digits,
/// OFL licence) is used under the same family name.
abstract final class AppTypography {
  static const fontFamily = 'AppFont';

  static TextStyle _style(double size, double lineHeight, FontWeight weight) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: weight,
        color: AppColors.textBody,
        leadingDistribution: TextLeadingDistribution.even,
      );

  // Headings (bold)
  static final heading1 = _style(22, 30, FontWeight.w700);
  static final heading2 = _style(18, 26, FontWeight.w700);
  static final heading3 = _style(16, 24, FontWeight.w500);

  // Body
  static final bodyLarge = _style(15, 24, FontWeight.w400);
  static final bodyMedium = _style(13, 20, FontWeight.w400);
  static final bodySmall = _style(12, 18, FontWeight.w400);

  // Labels
  static final labelLarge = _style(14, 20, FontWeight.w500);
  static final labelSmall = _style(11, 16, FontWeight.w400);
}
