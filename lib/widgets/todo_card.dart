import 'package:flutter/material.dart';
import '../models/todo.dart';

/// A reusable TodoCard widget to display a single todo in a polished card.
class TodoCard extends StatefulWidget {
  final Todo todo;
  final ValueChanged<bool?>? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    this.onComplete,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    final completed = todo.completed;
    final due = todo.dueDate;
    final theme = Theme.of(context);

    Color priorityBg;
    Color priorityFg;
    switch (todo.priority) {
      case Priority.high:
        priorityBg = const Color(0xFFFFF1F1);
        priorityFg = const Color(0xFFD32F2F);
        break;
      case Priority.medium:
        priorityBg = const Color(0xFFFFF8E1);
        priorityFg = const Color(0xFFF57C00);
        break;
      case Priority.low:
        priorityBg = const Color(0xFFE8F5E9);
        priorityFg = const Color(0xFF388E3C);
        break;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey(todo.id),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: AnimatedScale(
          scale: hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: hovered
                    ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                    : [Colors.black.withOpacity(0.08), Colors.black.withOpacity(0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: hovered 
                      ? theme.colorScheme.primary.withOpacity(0.18)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: hovered ? 18 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: completed,
                    onChanged: widget.onComplete,
                    activeColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: completed ? TextDecoration.lineThrough : null,
                            color: completed ? theme.colorScheme.onSurfaceVariant.withOpacity(0.6) : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          todo.description ?? 'No description provided',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                todo.category,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: priorityBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                todo.priority.name.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: priorityFg,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (due != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today, size: 10, color: theme.colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Due: ${due.day}/${due.month}/${due.year}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                        tooltip: 'Edit',
                        onPressed: widget.onEdit,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        tooltip: 'Delete',
                        onPressed: widget.onDelete,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
