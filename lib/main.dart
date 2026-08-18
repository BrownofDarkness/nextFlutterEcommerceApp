import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/favorites/providers/favorites_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load French locale data for `intl` — required before any DateFormat call
  // targeting `fr_FR`. Only loading the one locale we need keeps the binary
  // lean (the full locale bundle is ~2MB).
  await initializeDateFormatting('fr_FR', null);

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
    );
  }
}
