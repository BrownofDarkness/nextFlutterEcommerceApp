import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load locale data for intl — required before any DateFormat call.
  await Future.wait([
    initializeDateFormatting('fr_FR', null),
    initializeDateFormatting('en', null),
  ]);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const NextShopApp(),
    ),
  );
}

class NextShopApp extends StatelessWidget {
  const NextShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'next_shop',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
      supportedLocales: const [Locale('fr'), Locale('en')],
      localeResolutionCallback: (deviceLocale, supported) {
        for (final locale in supported) {
          if (deviceLocale?.languageCode == locale.languageCode) return locale;
        }
        return const Locale('fr');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
