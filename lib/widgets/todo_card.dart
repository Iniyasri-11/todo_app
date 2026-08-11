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
          scale: hovered ? 1.015 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Card(
            elevation: hovered ? 10 : 4,
            shadowColor: theme.colorScheme.primary.withOpacity(0.12),
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(value: completed, onChanged: widget.onComplete, activeColor: theme.colorScheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          todo.description ?? 'No description provided',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              label: Text(todo.category),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: theme.colorScheme.secondaryContainer,
                            ),
                            Chip(
                              label: Text(todo.priority.name.toUpperCase()),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: theme.colorScheme.tertiaryContainer,
                            ),
                            if (due != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text('Due: ${due.day}/${due.month}/${due.year}', style: theme.textTheme.bodySmall),
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
                      IconButton(icon: const Icon(Icons.edit), tooltip: 'Edit', onPressed: widget.onEdit),
                      IconButton(icon: const Icon(Icons.delete), tooltip: 'Delete', onPressed: widget.onDelete),
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
