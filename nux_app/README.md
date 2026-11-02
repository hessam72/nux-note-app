# Nux

Flutter (Android) app built from the Figma design system: **mobile-number login → OTP → home**.
The whole UI is Persian / right-to-left.

## Install

The pre-built APK is in `release/`:

- `nux-app.apk` — universal build (works on all phones, ~20 MB)

It is signed with the Flutter debug key, so Android may ask you to allow installs from unknown sources.

## What's inside

| Screen | File | Notes |
| --- | --- | --- |
| Login (mobile number) | `lib/features/auth/login_screen.dart` | Animated hero (character, avatar bubble, leaf, sparkles, wavy sheet), validation with shake, loading button |
| OTP | `lib/features/auth/otp_screen.dart` | 4 boxes, bubble + "drawn" check illustration, 20 s resend countdown, support link |
| Home | `lib/features/home/home_screen.dart` | Placeholder (no design yet) + logout |

There is no backend yet: "sending" and "verifying" the code are simulated, and **any 4-digit code is accepted**.

Transitions (`lib/core/routing/app_routes.dart`):

- login → OTP: horizontal shared-axis (slide along the reading direction + cross-fade)
- OTP → home / logout → login: fade-through with a soft scale

## Design system (`lib/core/design/`)

| File | Source page in Figma |
| --- | --- |
| `app_colors.dart` | Colors — primary (indigo) and gray scales 50→950, status colours |
| `app_spacing.dart` | Radius / Padding — spacing 4/8/12/16/24/32/48, radius small 8 / medium 12 / large 20 / full 999 |
| `app_typography.dart` | Typography — headings 22/30, 18/26, 16/24; body 15/24, 13/20, 12/18; labels 14/20, 11/16 |
| `app_theme.dart` | Material theme built from the tokens |

Reusable widgets live in `lib/core/widgets/` (`AppButton`, `AppTextField`, `Reveal` stagger helper, `Shake`).

### Font

The design uses **IranYekanX FaNum**, which isn't bundled. Until its files are added, the app uses
**Vazirmatn (Farsi-digits build, OFL licence)** under the family name `AppFont`.

To switch, copy the IranYekanX FaNum regular / medium / bold `.ttf` files into `assets/fonts/` and update the
three `asset:` paths under `fonts:` in `pubspec.yaml`. Nothing else changes.

### Assets

- `assets/svg/blue_tick.svg`, `yellow_avatar.svg`, `blue_leaf.svg` — the icons from Figma, unchanged.
- `assets/svg/blue_tick_bubble.svg` — `blue_tick.svg` without the check mark (the check is drawn in code so it can animate).
- `assets/svg/sparkle.svg` — the 4-point star from `blue_tick.svg`, tinted in code.
- `assets/images/lady.webp` — the character raster that was embedded inside the Figma SVG (extracted, 1.6 MB → 240 KB).

## Run / build

```bash
flutter pub get
flutter test
flutter build apk --release
```

Compare the screens with the design mock-ups (writes PNGs to `build/screenshots/`, 390×844 @2x):

```bash
flutter test tool/render_screens_test.dart
```
