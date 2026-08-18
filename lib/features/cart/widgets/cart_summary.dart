import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../providers/cart_provider.dart';

/// Sticky bottom summary + checkout button.
///
/// Reads three derived providers:
/// - [cartTotalProvider] for the sum
/// - [cartItemCountProvider] for the plural in the confirmation dialog
/// - [cartProvider] only via `.notifier.clear()` in the checkout flow
class CartSummary extends ConsumerWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(cartTotalProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.borderHairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _summaryRow(
                context,
                label: 'Sous-total',
                value: Formatters.euros(total),
              ),
              const SizedBox(height: 8),
              _summaryRow(
                context,
                label: 'Livraison',
                value: 'Gratuite',
                valueColor: const Color(0xFF4ADE80),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: text.titleMedium),
                  Text(
                    Formatters.euros(total),
                    style: text.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _checkout(context, ref),
                child: const Text('Passer la commande'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final text = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: text.bodyMedium),
        Text(
          value,
          style: text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final total = ref.read(cartTotalProvider);
    final count = ref.read(cartItemCountProvider);
    final label = count > 1 ? '$count articles' : '$count article';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer la commande'),
        content: Text(
          'Valider votre commande de $label pour un total de ${Formatters.euros(total)} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    ref.read(cartProvider.notifier).clear();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Merci pour votre commande !'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
  }
}
