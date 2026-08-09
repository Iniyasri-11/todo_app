import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';
import '../services/todo_api_service.dart';

/// Todo repository with optional remote sync. Implements ChangeNotifier so UI
/// can listen for updates. When `apiService` is provided and `syncWithRemote` is
/// true, the repository will attempt to fetch and push changes to the remote API.
class TodoRepository extends ChangeNotifier {
  final List<Todo> _todos = [];
  final TodoApiService? apiService;
  final bool syncWithRemote;
  final String currentUserId = 'user-1';
  bool _isLoading = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOffline => apiService == null || !syncWithRemote;

  TodoRepository({this.apiService, this.syncWithRemote = false}) {
    // Load persisted todos; if none, seed with example data or fetch remote when enabled
    _loadFromPrefs();
  }

  static const _prefsKey = 'todos_v1';

  Future<void> _loadFromPrefs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) {
        // no local data; attempt to fetch from remote if configured
        if (apiService != null && syncWithRemote) {
          try {
            final remote = await apiService!.fetchTodos();
            _todos.clear();
            _todos.addAll(remote);
            _saveToPrefs();
            return;
          } catch (error) {
            _errorMessage = 'Remote load failed, using local seed data.';
          }
        }

        // seed local examples for the current user
        final now = DateTime.now();
        _todos.addAll([
          Todo(
            id: 't1',
            userId: currentUserId,
            title: 'Learn Flutter',
            description: 'Complete Flutter Todo project',
            priority: Priority.high,
            category: 'Study',
            dueDate: now.add(const Duration(days: 2)),
          ),
          Todo(
            id: 't2',
            userId: currentUserId,
            title: 'Complete Assignment',
            description: 'Finish college assignment',
            priority: Priority.medium,
            category: 'College',
            dueDate: now.add(const Duration(days: 3)),
            completed: true,
          ),
        ]);
        _saveToPrefs();
        return;
      }

      final list = json.decode(raw) as List<dynamic>;
      _todos.clear();
      for (final item in list) {
        try {
          _todos.add(Todo.fromJson(Map<String, dynamic>.from(item as Map)));
        } catch (_) {}
      }

      // if remote sync enabled, attempt to merge/fetch remote
      if (apiService != null && syncWithRemote) {
        try {
          final remote = await apiService!.fetchTodos();
          if (remote.isNotEmpty) {
            _todos.clear();
            _todos.addAll(remote);
            _saveToPrefs();
          }
        } catch (error) {
          _errorMessage = 'Remote sync failed; showing local data.';
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load saved todos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _todos.map((t) => t.toJson()).toList();
      await prefs.setString(_prefsKey, json.encode(list));
    } catch (e) {
      // ignore save errors for now
    }
  }

  List<Todo> get todos => List.unmodifiable(_todos);

  void addTodo(Todo todo) {
    final newTodo = todo.userId == null ? todo.copyWith(userId: currentUserId) : todo;
    _todos.add(newTodo);
    notifyListeners();
    _saveToPrefs();

    if (apiService != null && syncWithRemote) {
      apiService!.createTodo(newTodo).catchError((_) {
        return newTodo;
      });
    }
  }

  void updateTodo(Todo todo) {
    final idx = _todos.indexWhere((t) => t.id == todo.id);
    if (idx != -1) {
      _todos[idx] = todo;
      notifyListeners();
      _saveToPrefs();

      if (apiService != null && syncWithRemote) {
        apiService!.updateTodo(todo).catchError((_) {
          return todo;
        });
      }
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
    _saveToPrefs();

    if (apiService != null && syncWithRemote) {
      apiService!.deleteTodo(id).catchError((_) {
        return Future.value();
      });
    }
  }

  void toggleComplete(String id, bool completed) {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _todos[idx] = _todos[idx].copyWith(completed: completed, updatedAt: DateTime.now());
      notifyListeners();
      _saveToPrefs();

      if (apiService != null && syncWithRemote) {
        apiService!.updateTodo(_todos[idx]).catchError((_) {
          return _todos[idx];
        });
      }
    }
  }
}
