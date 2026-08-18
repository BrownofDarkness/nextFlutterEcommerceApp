import 'package:flutter/material.dart';

/// Error state for failed `AsyncValue`s.
///
/// [message] should be a human-friendly explanation (not the raw exception).
/// [onRetry] optionally shows a "Réessayer" button that typically calls
/// `ref.invalidate(theProvider)` at the caller side.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: scheme.error.withValues(alpha: 0.4)),
              ),
              child: Icon(Icons.error_outline, size: 36, color: scheme.error),
            ),
            const SizedBox(height: 20),
            Text('Une erreur est survenue', style: text.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
