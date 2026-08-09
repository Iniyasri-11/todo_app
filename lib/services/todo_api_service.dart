import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class TodoApiService {
  final String baseUrl;
  final http.Client client;

  TodoApiService({required this.baseUrl, http.Client? client}) : client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse(baseUrl + path);

  Future<List<Todo>> fetchTodos() async {
    final res = await client.get(_uri('/todos'));
    if (res.statusCode != 200) throw Exception('Failed to fetch todos');
    final list = json.decode(res.body) as List<dynamic>;
    return list.map((e) => Todo.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<Todo> createTodo(Todo todo) async {
    final res = await client.post(_uri('/todos'), body: json.encode(todo.toJson()), headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 201 && res.statusCode != 200) throw Exception('Failed to create todo');
    return Todo.fromJson(json.decode(res.body) as Map<String, dynamic>);
  }

  Future<Todo> updateTodo(Todo todo) async {
    final res = await client.put(_uri('/todos/${todo.id}'), body: json.encode(todo.toJson()), headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200) throw Exception('Failed to update todo');
    return Todo.fromJson(json.decode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteTodo(String id) async {
    final res = await client.delete(_uri('/todos/$id'));
    if (res.statusCode != 200 && res.statusCode != 204) throw Exception('Failed to delete todo');
  }
}
