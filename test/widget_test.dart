import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:next_shop/data/models/user_profile.dart';
import 'package:next_shop/features/catalog/providers/product_providers.dart';
import 'package:next_shop/features/favorites/providers/favorites_provider.dart';
import 'package:next_shop/features/profile/providers/user_provider.dart';
import 'package:next_shop/main.dart';

void main() {
  testWidgets('App boots on the catalog tab', (tester) async {
    // Mock persistence layer.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          // Override the async data providers so they resolve synchronously
          // without spawning `Future.delayed` timers — otherwise the widget
          // test binding complains about pending timers on tear-down.
          productsProvider.overrideWith((ref) async => []),
          userProvider.overrideWith(
            (ref) async => UserProfile(
              id: 'test',
              name: 'Test User',
              email: 'test@example.com',
              avatarUrl: '',
              memberSince: DateTime(2024),
            ),
          ),
        ],
        child: const NextShopApp(),
      ),
    );

    // Two pumps: one to initialize, one to let async providers resolve.
    await tester.pump();
    await tester.pump();

    expect(find.text('Catalogue'), findsWidgets);
  });
}
