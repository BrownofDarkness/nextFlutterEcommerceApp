import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/empty_view.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary.dart';

/// Cart tab.
///
/// Renders one of two bodies based on cart emptiness — no separate route,
/// no separate page. The `Notifier` layer already knows the list; the widget
/// reacts. This is the natural Riverpod flow: state drives UI, not the other
/// way around.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final count = items.fold<int>(0, (sum, i) => sum + i.quantity);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(count: count),
            Expanded(
              child: items.isEmpty
                  ? _EmptyBody()
                  : _FilledBody(itemCount: items.length),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final subtitle = switch (count) {
      0 => 'Aucun article',
      1 => '1 article',
      _ => '$count articles',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Panier', style: text.headlineLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: Icons.shopping_bag_outlined,
      title: 'Votre panier est vide',
      subtitle:
          'Découvrez notre catalogue et ajoutez vos premiers produits.',
      actionLabel: 'Découvrir le catalogue',
      onAction: () => context.go(RouteNames.catalog),
    );
  }
}

class _FilledBody extends ConsumerWidget {
  const _FilledBody({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-read inside this widget so [_FilledBody] rebuilds when items change
    // WITHOUT rebuilding the parent's header structure.
    final items = ref.watch(cartProvider);

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 300),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) => CartItemTile(item: items[i]),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: CartSummary(),
        ),
      ],
    );
  }
}
