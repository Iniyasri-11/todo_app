import 'package:flutter/material.dart';
import '../models/todo.dart';

/// Reusable TodoForm widget used inside dialogs for Add / Edit.
///
/// File: lib/widgets/todo_form.dart
///
/// This form returns a `Map<String, dynamic>` when submitted with keys:
/// `title`, `description`, `priority`, `category`, `dueDate`.
class TodoForm extends StatefulWidget {
  final Todo? initialTodo;

  const TodoForm({super.key, this.initialTodo});

  @override
  State<TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _priority = 'Medium';
  String _category = 'Study';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTodo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.initialTodo?.description ?? '');
    final p = widget.initialTodo?.priority;
    _priority = p == null ? 'Medium' : p.name[0].toUpperCase() + p.name.substring(1);
    _category = widget.initialTodo?.category ?? 'Study';
    _dueDate = widget.initialTodo?.dueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final id = widget.initialTodo?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
      final todo = Todo(
        id: id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        priority: _parsePriority(_priority),
        category: _category,
        dueDate: _dueDate,
      );

      Navigator.of(context).pop(todo);
    }
  }

  Priority _parsePriority(String label) {
    final lower = label.toLowerCase();
    if (lower.startsWith('h')) return Priority.high;
    if (lower.startsWith('l')) return Priority.low;
    return Priority.medium;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Title is required';
              if (v.trim().length < 3) return 'Title must be at least 3 characters';
              return null;
            },
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
            maxLines: 3,
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority', prefixIcon: Icon(Icons.flag)),
            items: const [
              DropdownMenuItem(value: 'High', child: Text('High')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'Low', child: Text('Low')),
            ],
            onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
            validator: (v) => v == null || v.isEmpty ? 'Select priority' : null,
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
            items: const [
              DropdownMenuItem(value: 'Study', child: Text('Study')),
              DropdownMenuItem(value: 'College', child: Text('College')),
              DropdownMenuItem(value: 'Work', child: Text('Work')),
              DropdownMenuItem(value: 'Personal', child: Text('Personal')),
            ],
            onChanged: (v) => setState(() => _category = v ?? 'Study'),
            validator: (v) => v == null || v.isEmpty ? 'Select category' : null,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 12),
              Expanded(child: Text('Due Date: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}')),
              TextButton(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (selected != null) setState(() => _dueDate = selected);
                },
                child: const Text('Select'),
              )
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _submit, child: const Text('Save')),
            ],
          )
        ],
      ),
    );
  }
}
