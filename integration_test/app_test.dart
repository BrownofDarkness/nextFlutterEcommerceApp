import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:next_shop/main.dart' as app;

/// Tests d'intégration — nécessitent un device ou émulateur connecté.
/// Lancer avec : flutter test integration_test/
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('L\'app démarre et affiche la barre de navigation',
      (tester) async {
    app.main();

    // Deux passes : initialisation + résolution async (SharedPreferences, intl)
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // La barre de navigation avec ses 4 onglets est visible
    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text('Panier'), findsOneWidget);
    expect(find.text('Favoris'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('La navigation vers l\'onglet Panier fonctionne', (tester) async {
    app.main();

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Tap sur l'onglet Panier
    await tester.tap(find.text('Panier'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // La page Panier est affichée (titre + état vide)
    expect(find.text('Votre panier est vide'), findsOneWidget);
  });
}
