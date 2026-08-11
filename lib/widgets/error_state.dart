import 'package:flutter/material.dart';

/// A premium, reusable error panel displaying detailed warning information,
/// technical developer logs in an expandable tray, and recovery actions.
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String? errorDetails;
  final VoidCallback onRetry;
  final String retryLabel;

  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.errorDetails,
    required this.onRetry,
    this.retryLabel = 'Retry Connection',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          color: theme.colorScheme.surface,
          shadowColor: theme.colorScheme.error.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Warning Circular Shell
                Container(
                  height: 96,
                  width: 96,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.2),
                      width: 4,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Clear bold Header
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Friendly error message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                
                // Destructive styled primary action button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    retryLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  onPressed: onRetry,
                ),

                // Technical Logs Expandable Drawer
                if (errorDetails != null && errorDetails!.trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Icon(Icons.bug_report_outlined, size: 20, color: theme.colorScheme.error),
                      title: Text(
                        'Technical Logs',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      childrenPadding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.colorScheme.errorContainer,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            errorDetails!.trim(),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
