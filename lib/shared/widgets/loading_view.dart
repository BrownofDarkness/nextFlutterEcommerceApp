import 'package:flutter/material.dart';

import 'skeleton.dart';

/// Generic shimmer-based loading placeholder.
///
/// Use as the default `.when(loading: ...)` fallback when no page-specific
/// skeleton is provided. For richer UX, prefer a dedicated skeleton per page
/// (e.g. a grid of `ProductCardSkeleton` for the catalog) — the shimmer will
/// then mimic the final layout, which feels considerably more polished.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonBox(width: 180, height: 28, borderRadius: 6),
            SizedBox(height: 8),
            SkeletonBox(width: 80, height: 14, borderRadius: 4),
            SizedBox(height: 24),
            SkeletonBox(
                width: double.infinity, height: 180, borderRadius: 16),
            SizedBox(height: 16),
            SkeletonBox(
                width: double.infinity, height: 180, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}
