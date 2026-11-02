import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nux_app/app.dart';
import 'package:nux_app/features/auth/login_screen.dart';
import 'package:nux_app/features/auth/otp_screen.dart';
import 'package:nux_app/features/home/home_screen.dart';

Future<void> _pump(WidgetTester tester, int milliseconds) async {
  // Several short pumps so every animation / delayed call gets a frame.
  for (var elapsed = 0; elapsed < milliseconds; elapsed += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('login → OTP → home → logout', (tester) async {
    tester.view
      ..physicalSize = const Size(780, 1688)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const NuxApp());
    await _pump(tester, 2000);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('ورود به حساب کاربری'), findsOneWidget);

    // The app is right-to-left.
    final context = tester.element(find.byType(LoginScreen));
    expect(Directionality.of(context), TextDirection.rtl);

    // Empty / invalid number → inline error, stays on the page.
    await tester.tap(find.text('ورود'));
    await _pump(tester, 600);
    expect(find.textContaining('معتبر نیست'), findsOneWidget);
    expect(find.byType(OtpScreen), findsNothing);

    await tester.enterText(find.byType(TextField), '0912123');
    await tester.tap(find.text('ورود'));
    await _pump(tester, 600);
    expect(find.byType(OtpScreen), findsNothing);

    // Typing clears the error; a valid number goes to the OTP page.
    await tester.enterText(find.byType(TextField), '۰۹۱۲۱۲۳۴۵۶۷');
    await _pump(tester, 300);
    expect(find.textContaining('معتبر نیست'), findsNothing);
    await tester.tap(find.text('ورود'));
    await _pump(tester, 1200 + 1000); // fake request + page transition
    expect(find.byType(OtpScreen), findsOneWidget);
    expect(find.textContaining('۰۹۱۲۱۲۳۴۵۶۷'), findsOneWidget);
    expect(find.text('ارسال مجدد کد بعد از '), findsOneWidget);

    // Too short a code → stays; 4 digits → home.
    await tester.enterText(find.byType(TextField), '12');
    await tester.tap(find.text('ارسال'));
    await _pump(tester, 600);
    expect(find.byType(HomeScreen), findsNothing);

    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('ارسال'));
    await _pump(tester, 1200 + 1000);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(OtpScreen), findsNothing);
    expect(find.textContaining('۰۹۱۲۱۲۳۴۵۶۷'), findsOneWidget);

    // Logout goes back to a fresh login page.
    await tester.tap(find.text('خروج از حساب'));
    await _pump(tester, 1000);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('OTP countdown ticks and offers a resend', (tester) async {
    tester.view
      ..physicalSize = const Size(780, 1688)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const NuxApp(home: OtpScreen(phone: '09121234567')),
    );
    await _pump(tester, 1000);
    expect(find.text('ارسال مجدد کد بعد از '), findsOneWidget);

    await _pump(tester, 20000);
    expect(find.text('ارسال مجدد کد'), findsOneWidget);
    expect(find.text('ارسال مجدد کد بعد از '), findsNothing);

    // Dispose the page so its timer / controllers are released.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
