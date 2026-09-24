import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_shop/shared/widgets/empty_view.dart';

import '../helpers/test_wrapper.dart';

void main() {
  group('EmptyView', () {
    testWidgets('affiche le titre', (tester) async {
      await tester.pumpWidget(testWrapper(
        const EmptyView(
          icon: Icons.shopping_bag_outlined,
          title: 'Titre test',
        ),
      ));

      expect(find.text('Titre test'), findsOneWidget);
    });

    testWidgets('affiche le sous-titre quand fourni', (tester) async {
      await tester.pumpWidget(testWrapper(
        const EmptyView(
          icon: Icons.shopping_bag_outlined,
          title: 'Titre',
          subtitle: 'Sous-titre test',
        ),
      ));

      expect(find.text('Sous-titre test'), findsOneWidget);
    });

    testWidgets('affiche le bouton quand actionLabel est fourni',
        (tester) async {
      await tester.pumpWidget(testWrapper(
        EmptyView(
          icon: Icons.shopping_bag_outlined,
          title: 'Titre',
          actionLabel: 'Action',
          onAction: () {},
        ),
      ));

      expect(find.widgetWithText(FilledButton, 'Action'), findsOneWidget);
    });

    testWidgets('masque le bouton quand actionLabel est null', (tester) async {
      await tester.pumpWidget(testWrapper(
        const EmptyView(
          icon: Icons.shopping_bag_outlined,
          title: 'Titre',
        ),
      ));

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('appelle onAction au tap sur le bouton', (tester) async {
      var tapped = false;
      await tester.pumpWidget(testWrapper(
        EmptyView(
          icon: Icons.shopping_bag_outlined,
          title: 'Titre',
          actionLabel: 'Appuie',
          onAction: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(FilledButton));
      expect(tapped, isTrue);
    });
  });
}
