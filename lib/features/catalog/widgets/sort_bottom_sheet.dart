import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_filter.dart';
import '../providers/filter_provider.dart';

/// Bottom sheet for choosing a [SortOption]. Opens via
/// [showModalBottomSheet] from the catalog page header.
class SortBottomSheet extends ConsumerWidget {
  const SortBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SortBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSort = ref.watch(filterProvider.select((f) => f.sort));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trier par', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final option in SortOption.values)
              _SortRow(
                option: option,
                selected: option == activeSort,
                onTap: () {
                  ref.read(filterProvider.notifier).setSort(option);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final SortOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? scheme.primary : null,
                    ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, color: scheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
