import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/repositories/todo_repository.dart';
import 'package:todo_app/services/todo_api_service.dart';

void main() {
  test('fetches remote todos on init when remote sync is enabled', () async {
    SharedPreferences.setMockInitialValues({});

    final service = TodoApiService(
      baseUrl: 'https://api.example.com',
      client: MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/todos') {
          return http.Response(
            json.encode([
              {
                'id': 'remote-1',
                'title': 'Remote todo',
                'description': 'Loaded from API',
                'completed': false,
                'priority': 'medium',
                'category': 'Work',
                'due_date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              }
            ]),
            200,
            headers: {'Content-Type': 'application/json'},
          );
        }

        return http.Response('Not Found', 404);
      }),
    );

    final repo = TodoRepository(apiService: service, syncWithRemote: true);
    await Future.delayed(const Duration(milliseconds: 200));

    expect(repo.todos, isNotEmpty);
    expect(repo.todos.first.title, 'Remote todo');
    expect(repo.todos.first.id, 'remote-1');
  });

  test('calls remote create endpoint on addTodo when sync is enabled', () async {
    SharedPreferences.setMockInitialValues({'todos_v1': '[]'});

    var createCalled = false;
    late Map<String, dynamic> requestBody;

    final service = TodoApiService(
      baseUrl: 'https://api.example.com',
      client: MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/todos') {
          return http.Response('[]', 200, headers: {'Content-Type': 'application/json'});
        }

        if (request.method == 'POST' && request.url.path == '/todos') {
          createCalled = true;
          requestBody = json.decode(request.body) as Map<String, dynamic>;
          return http.Response(request.body, 201, headers: {'Content-Type': 'application/json'});
        }

        return http.Response('Not Found', 404);
      }),
    );

    final repo = TodoRepository(apiService: service, syncWithRemote: true);
    await Future.delayed(const Duration(milliseconds: 200));

    final todo = Todo(id: 'created-1', title: 'Create remote', description: 'New task');
    repo.addTodo(todo);
    await Future.delayed(const Duration(milliseconds: 200));

    expect(createCalled, isTrue);
    expect(requestBody['id'], 'created-1');
    expect(repo.todos.any((t) => t.id == 'created-1'), isTrue);
  });
}
