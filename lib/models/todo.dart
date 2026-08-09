/// Todo model
/// File: lib/models/todo.dart
library;

enum Priority { high, medium, low }

class Todo {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final bool completed;
  final Priority priority;
  final String category;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Todo({
    required this.id,
    this.userId,
    required this.title,
    this.description,
    this.completed = false,
    this.priority = Priority.medium,
    this.category = 'General',
    this.dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with modifications.
  Todo copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? completed,
    Priority? priority,
    String? category,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Serialization to JSON-friendly map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'completed': completed,
      'priority': priority.name,
      'category': category,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Deserialization from JSON-like map.
  factory Todo.fromJson(Map<String, dynamic> json) {
    Priority parsePriority(String? value) {
      switch (value) {
        case 'high':
        case 'Priority.high':
        case 'High':
        case 'HIGH':
          return Priority.high;
        case 'low':
        case 'Priority.low':
        case 'Low':
        case 'LOW':
          return Priority.low;
        default:
          return Priority.medium;
      }
    }

    return Todo(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      completed: json['completed'] as bool? ?? false,
      priority: parsePriority(json['priority'] as String?),
      category: json['category'] as String? ?? 'General',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }
}
