import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/repositories/todo_repository.dart';

void main() {
  test('persist and load todos from SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});

    final repo = TodoRepository();

    // wait for async load
    await Future.delayed(const Duration(milliseconds: 200));

    expect(repo.todos.isNotEmpty, true);

    // add a new todo
    final todo = Todo(id: 'x1', title: 'Test persist', description: 'desc');
    repo.addTodo(todo);

    // allow save
    await Future.delayed(const Duration(milliseconds: 200));

    // create new repo instance to load from prefs
    final repo2 = TodoRepository();
    await Future.delayed(const Duration(milliseconds: 200));

    final found = repo2.todos.any((t) => t.id == 'x1');
    expect(found, true);
  });
}
