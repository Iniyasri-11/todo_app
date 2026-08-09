import 'todo.dart';

/// The type of synchronization operation.
enum SyncAction { insert, update, delete }

/// Represents a change that occurred offline and is queued for replication.
class SyncCommand {
  final String id;
  final SyncAction action;
  final Todo todo;
  final DateTime timestamp;

  SyncCommand({
    required this.id,
    required this.action,
    required this.todo,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
      'todo': todo.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SyncCommand.fromJson(Map<String, dynamic> json) {
    return SyncCommand(
      id: json['id'] as String,
      action: SyncAction.values.byName(json['action'] as String),
      todo: Todo.fromJson(json['todo'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
