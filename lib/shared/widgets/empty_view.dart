import 'package:flutter/material.dart';

/// Empty state used when a list has no items (empty cart, no favorites, no
/// search result). Consistent shape across the whole app so users learn the
/// pattern once.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert(
          (actionLabel == null) == (onAction == null),
          'Provide both actionLabel and onAction, or neither.',
        );

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outline),
              ),
              child: Icon(icon, size: 44, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Text(title, style: text.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: text.bodySmall,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
