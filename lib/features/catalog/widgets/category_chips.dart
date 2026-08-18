import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../providers/filter_provider.dart';

/// Horizontal scrollable row of category chips. The first chip ("Tous") maps
/// to `null` — the "no filter" state.
///
/// Uses `filterProvider.select((f) => f.category)` to rebuild ONLY when the
/// active category changes — a change to `sort` or `searchQuery` leaves the
/// chips untouched. This is the Riverpod pattern for surgical rebuilds.
class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final activeCategory =
        ref.watch(filterProvider.select((f) => f.category));

    return SizedBox(
      height: 40,
      child: categoriesAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (categories) {
          // Prepend `null` to represent the "Tous" chip.
          final entries = <String?>[null, ...categories];
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = entries[index];
              final isActive = activeCategory == category;
              final label =
                  category == null ? 'Tous' : Formatters.categoryLabel(category);
              return ChoiceChip(
                label: Text(label),
                selected: isActive,
                onSelected: (_) =>
                    ref.read(filterProvider.notifier).setCategory(category),
              );
            },
          );
        },
      ),
    );
  }
}