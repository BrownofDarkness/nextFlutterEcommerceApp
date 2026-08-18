import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/skeleton.dart';

/// Shimmer version of [ProductCard]. Mimics its exact layout so the loading
/// state doesn't visually jump when real data arrives.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderHairline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: const Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: SkeletonBox(borderRadius: 0),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 60, height: 10, borderRadius: 3),
                    SizedBox(height: 8),
                    SkeletonBox(
                        width: double.infinity, height: 14, borderRadius: 4),
                    SizedBox(height: 4),
                    SkeletonBox(width: 90, height: 14, borderRadius: 4),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBox(width: 72, height: 18, borderRadius: 4),
                        SkeletonBox(width: 40, height: 12, borderRadius: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
