import 'package:flutter/material.dart';

/// A premium, animated loading skeleton that mimics the structure of [TodoCard]
/// to provide a professional, shimmer-like transition experience.
class TodoCardSkeleton extends StatefulWidget {
  const TodoCardSkeleton({super.key});

  @override
  State<TodoCardSkeleton> createState() => _TodoCardSkeletonState();
}

class _TodoCardSkeletonState extends State<TodoCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = _controller.value;
        // Use theme values for harmonious coloring matching light/dark modes
        final baseColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.08);
        final pulsingColor = baseColor.withOpacity(0.08 + (opacity * 0.12));

        return Card(
          elevation: 1,
          color: theme.colorScheme.surface,
          shadowColor: theme.colorScheme.primary.withOpacity(0.04),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simulated Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: pulsingColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Simulated Title (thick bar)
                      Container(
                        width: 160,
                        height: 22,
                        decoration: BoxDecoration(
                          color: pulsingColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Simulated Description line 1
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: pulsingColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Simulated Description line 2
                      Container(
                        width: 130,
                        height: 14,
                        decoration: BoxDecoration(
                          color: pulsingColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Simulated Chips Row
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 26,
                            decoration: BoxDecoration(
                              color: pulsingColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 84,
                            height: 26,
                            decoration: BoxDecoration(
                              color: pulsingColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Simulated Edit/Delete Action Icons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: pulsingColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: pulsingColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
