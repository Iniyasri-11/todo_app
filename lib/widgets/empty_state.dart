import 'package:flutter/material.dart';

/// A premium, animated empty state widget used when no tasks match the filter
/// or when the workspace is completely clean. Includes a smooth entry animation.
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

    // Smooth mount scale-in and fade-in animation
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.85 + (value * 0.15),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Double glow ring icon structure
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.06),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.04),
                      blurRadius: 20,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    height: 92,
                    width: 92,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.task_alt_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title text
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              
              // Context message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Call to action button
              if (action != null && actionLabel != null)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 1,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  onPressed: action,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    actionLabel!,
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

