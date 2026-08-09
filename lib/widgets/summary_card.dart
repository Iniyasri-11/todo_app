import 'package:flutter/material.dart';

/// A small summary card used in dashboard to show counts (Total, Pending, etc.).
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: primary, size: 26),
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
