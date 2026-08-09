import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/todo.dart';

void main() {
  test('Todo serialization and deserialization', () {
    final now = DateTime.now();
    final todo = Todo(
      id: 't1',
      userId: 'u1',
      title: 'Test Todo',
      description: 'A description',
      completed: false,
      priority: Priority.high,
      category: 'Study',
      dueDate: now,
      createdAt: now,
      updatedAt: now,
    );

    final json = todo.toJson();

    expect(json['id'], 't1');
    expect(json['title'], 'Test Todo');

    final parsed = Todo.fromJson(json);

    expect(parsed.id, todo.id);
    expect(parsed.title, todo.title);
    expect(parsed.priority, Priority.high);
    expect(parsed.dueDate?.toIso8601String(), todo.dueDate?.toIso8601String());
  });
}
