// Renders the app screens to PNG files in build/screenshots/ so they can be
// compared with the design mock-ups:
//
//   flutter test tool/render_screens_test.dart
//
// The frame is 390×844 logical pixels at 2x (780×1688), the same size as the
// exported mock-ups.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nux_app/app.dart';
import 'package:nux_app/features/auth/login_screen.dart';
import 'package:nux_app/features/auth/otp_screen.dart';
import 'package:nux_app/features/home/home_screen.dart';

const _boundaryKey = ValueKey('screenshot-boundary');

Future<void> _loadFonts() async {
  final loader = FontLoader('AppFont');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('assets/fonts/Vazirmatn-FD-$weight.ttf')
        .readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Future<void> _settle(WidgetTester tester, Duration total) async {
  const step = Duration(milliseconds: 100);
  var elapsed = Duration.zero;
  while (elapsed < total) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(step);
    elapsed += step;
  }
}

Future<void> _capture(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_boundaryKey),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final file = File('build/screenshots/$name.png')..createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

void main() {
  testWidgets('render screens', (tester) async {
    await _loadFonts();
    tester.view
      ..physicalSize = const Size(780, 1688)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const RepaintBoundary(key: _boundaryKey, child: NuxApp()),
    );
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/images/lady.webp'),
        tester.element(find.byType(LoginScreen)),
      );
    });

    await _settle(tester, const Duration(milliseconds: 500));
    await _capture(tester, '01_login_intro');
    await _settle(tester, const Duration(milliseconds: 2500));
    await _capture(tester, '02_login');

    // Validation error state.
    await tester.tap(find.text('ورود'));
    await _settle(tester, const Duration(milliseconds: 800));
    await _capture(tester, '03_login_error');

    // OTP.
    await tester.enterText(find.byType(TextField), '09121234567');
    await tester.tap(find.text('ورود'));
    await _settle(tester, const Duration(milliseconds: 4200));
    expect(find.byType(OtpScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField), '555');
    await _settle(tester, const Duration(milliseconds: 600));
    await _capture(tester, '04_otp');

    // Home.
    await tester.enterText(find.byType(TextField), '5555');
    await tester.tap(find.text('ارسال'));
    await _settle(tester, const Duration(milliseconds: 3500));
    expect(find.byType(HomeScreen), findsOneWidget);
    await _capture(tester, '05_home');
  });
}
