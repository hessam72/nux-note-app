import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/design/app_theme.dart';
import 'features/auth/login_screen.dart';

class NuxApp extends StatelessWidget {
  const NuxApp({super.key, this.home = const LoginScreen()});

  /// First screen (overridable for tests).
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nux',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // The whole app is Persian / right-to-left.
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }
}
