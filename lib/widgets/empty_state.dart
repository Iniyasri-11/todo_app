import 'package:flutter/material.dart';

/// Professional empty state used when there are no todos to show.
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? action;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 112,
              width: 112,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(Icons.task_alt, size: 56, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            if (action != null && actionLabel != null)
              FilledButton(onPressed: action, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}
