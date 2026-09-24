import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_shop/core/theme/app_theme.dart';
import 'package:next_shop/l10n/app_localizations.dart';

/// Dark MaterialApp with French locale — no ProviderScope.
/// Use when the test builds its own ProviderScope with custom overrides.
Widget testMaterialApp(Widget child) {
  return MaterialApp(
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.dark,
    locale: const Locale('fr'),
    supportedLocales: const [Locale('fr'), Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

/// Convenience wrapper: ProviderScope (no overrides) + dark MaterialApp FR.
/// Use when the widget under test uses providers but needs no override.
Widget testWrapper(Widget child) {
  return ProviderScope(child: testMaterialApp(child));
}
