/// Spacing + radius tokens from the "Radius / Padding" page of the design system.
abstract final class AppSpacing {
  /// Spacing scale: 4 / 8 / 12 / 16 / 24 / 32 / 48 (logical pixels).
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;

  /// Inner padding of cards.
  static const double cardPadding = s16;

  /// Side margin of a page: 16 – 20.
  static const double pageMarginMin = 16;
  static const double pageMarginMax = 20;

  /// Gap between list items.
  static const double listGap = s12;

  /// Side margin used by the auth screens (measured from their mock-ups).
  static const double authMargin = 31;
}

abstract final class AppRadius {
  /// `radius/small`: input fields.
  static const double small = 8;

  /// `radius/medium`: buttons.
  static const double medium = 12;

  /// `radius/large`: cards, image panels.
  static const double large = 20;

  /// `radius/full`: badges, circular icons, bottom bar.
  static const double full = 999;
}
