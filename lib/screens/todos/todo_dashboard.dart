import 'package:flutter/material.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/todo_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/todo_form.dart';
import '../../models/todo.dart';
import '../../repositories/todo_repository.dart';
import '../../providers/todo_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// removed unused foundation import

/// Dashboard screen moved from the original `main.dart`.
///
/// This file contains the Todo list UI used in Phase 1. Later phases
/// will replace the in-memory list with repositories and services.
class TodoDashboard extends ConsumerStatefulWidget {
  const TodoDashboard({super.key});

  @override
  ConsumerState<TodoDashboard> createState() => _TodoDashboardState();
}

class _TodoDashboardState extends ConsumerState<TodoDashboard> {
  late final TodoRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(todoRepositoryProvider);
    _repo.addListener(_onRepoChanged);
  }

  void _onRepoChanged() => setState(() {});

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  String searchText = '';
  String filter = 'All';
  String sortBy = 'Due Date';

  List<Todo> get filteredTodos {
    final base = _repo.todos;

    final searched = base.where((todo) {
      final title = todo.title.toLowerCase();
      final description = (todo.description ?? '').toLowerCase();
      return title.contains(searchText.toLowerCase()) || description.contains(searchText.toLowerCase());
    });

    final filtered = searched.where((todo) {
      if (filter == 'Pending') return todo.completed == false;
      if (filter == 'Completed') return todo.completed == true;
      if (filter == 'High Priority') return todo.priority == Priority.high;
      if (filter == 'Medium Priority') return todo.priority == Priority.medium;
      if (filter == 'Low Priority') return todo.priority == Priority.low;
      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (sortBy) {
        case 'Title':
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case 'Priority':
          return a.priority.index.compareTo(b.priority.index);
        case 'Category':
          return a.category.toLowerCase().compareTo(b.category.toLowerCase());
        case 'Due Date':
        default:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
      }
    });

    return filtered;
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void showTodoForm({Todo? existingTodo}) {
    // Use the reusable TodoForm. The form now returns a Todo on submit.
    showDialog<Todo>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingTodo == null ? 'Add New Todo' : 'Edit Todo'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: TodoForm(initialTodo: existingTodo),
            ),
          ),
        );
      },
    ).then((todo) {
      if (todo == null) return;
      if (existingTodo == null) {
        _repo.addTodo(todo);
      } else {
        _repo.updateTodo(todo.copyWith(updatedAt: DateTime.now()));
      }
    });
  }

  // priority parsing moved into TodoForm; no local parsing required.

  void deleteTodo(int index) {
    final todo = filteredTodos[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Todo?'),
          content: Text('Are you sure you want to delete "${todo.title}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () {
              _repo.deleteTodo(todo.id);
              Navigator.pop(context);
            }, child: const Text('Delete')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedTodos = filteredTodos;
    final theme = Theme.of(context);

    if (_repo.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Todo Management App'),
          backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo Management App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                '${_repo.todos.length} Tasks',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
        backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),

      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.12),
                theme.colorScheme.secondary.withOpacity(0.08),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.28),
                          theme.colorScheme.primaryContainer.withOpacity(0.26),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Your tasks, organized beautifully',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Keep track of your priorities and deadlines with a clean workspace.',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Chip(
                              label: Text('${_repo.todos.length} tasks total'),
                              avatar: const Icon(Icons.task_alt, size: 18),
                              backgroundColor: theme.colorScheme.secondaryContainer,
                            ),
                            Chip(
                              label: Text('${_repo.todos.where((t) => !t.completed).length} pending'),
                              avatar: const Icon(Icons.pending_actions, size: 18),
                              backgroundColor: theme.colorScheme.tertiaryContainer,
                            ),
                            FilledButton(
                              onPressed: () => showTodoForm(),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 8),
                                  Text('Add Task'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 720;
                      final cardWidth = isWide ? (constraints.maxWidth - 28) / 3 : constraints.maxWidth;

                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: SummaryCard(
                              title: 'Total Tasks',
                              value: '${_repo.todos.length}',
                              icon: Icons.list_alt,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: SummaryCard(
                              title: 'Pending',
                              value: '${_repo.todos.where((t) => !t.completed).length}',
                              icon: Icons.pending_actions,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: SummaryCard(
                              title: 'Completed',
                              value: '${_repo.todos.where((t) => t.completed).length}',
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search tasks...',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: searchText.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              searchText = '';
                                            });
                                          },
                                          icon: const Icon(Icons.clear),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            FilledButton(
                              onPressed: () => showTodoForm(),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 8),
                                  Text('Add Task'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              filterButton('All'),
                              filterButton('Pending'),
                              filterButton('Completed'),
                              filterButton('High Priority'),
                              filterButton('Medium Priority'),
                              filterButton('Low Priority'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Sort by:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: sortBy,
                                  dropdownColor: theme.colorScheme.surface,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                                  iconEnabledColor: theme.colorScheme.primary,
                                  items: const [
                                    DropdownMenuItem(value: 'Due Date', child: Text('Due Date')),
                                    DropdownMenuItem(value: 'Priority', child: Text('Priority')),
                                    DropdownMenuItem(value: 'Category', child: Text('Category')),
                                    DropdownMenuItem(value: 'Title', child: Text('Title')),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      sortBy = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (_repo.isOffline)
                              Chip(
                                label: const Text('Offline Mode'),
                                backgroundColor: theme.colorScheme.secondaryContainer,
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_repo.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _repo.errorMessage!,
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (displayedTodos.isEmpty)
                          EmptyState(
                            title: 'You are all caught up!',
                            message: 'Add a new task to stay productive and track your progress.',
                            action: () => showTodoForm(),
                            actionLabel: 'Create Todo',
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final wide = constraints.maxWidth > 720;

                              if (wide) {
                                return GridView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2.2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: displayedTodos.length,
                                  itemBuilder: (context, index) {
                                    final todo = displayedTodos[index];
                                    return TodoCard(
                                      todo: todo,
                                      onComplete: (value) => _repo.toggleComplete(todo.id, value ?? false),
                                      onEdit: () => showTodoForm(existingTodo: todo),
                                      onDelete: () => deleteTodo(index),
                                    );
                                  },
                                );
                              }

                              return ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: displayedTodos.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final todo = displayedTodos[index];
                                  return TodoCard(
                                    todo: todo,
                                    onComplete: (value) => _repo.toggleComplete(todo.id, value ?? false),
                                    onEdit: () => showTodoForm(existingTodo: todo),
                                    onDelete: () => deleteTodo(index),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget filterButton(String name) {
    final selected = filter == name;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(name),
        selected: selected,
        selectedColor: theme.colorScheme.primaryContainer,
        backgroundColor: theme.colorScheme.secondaryContainer,
        labelStyle: TextStyle(
          color: selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        onSelected: (_) {
          setState(() {
            filter = name;
          });
        },
      ),
    );
  }
}

