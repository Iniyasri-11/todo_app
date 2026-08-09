import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import '../models/sync_queue.dart';
import '../services/supabase_service.dart';
import 'auth_repository.dart';

/// Offline-First repository for managing Todos.
///
/// Implements local persistence via SharedPreferences, optimistic UI updates,
/// a persistent write queue for offline mode, and automatic/manual sync replays
/// with Last-Write-Wins conflict resolution.
class TodoRepository extends ChangeNotifier {
  final AuthRepository authRepository;
  final List<Todo> _todos = [];
  final List<SyncCommand> _syncQueue = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineSimulated = false; // Manually toggleable via UI for offline testing
  StreamSubscription<List<Todo>>? _realtimeSubscription;

  TodoRepository({required this.authRepository}) {
    _init();
    authRepository.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    _todos.clear();
    _syncQueue.clear();
    _errorMessage = null;
    _init();
  }

  Future<void> _init() async {
    if (!authRepository.isAuthenticated) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Load from local cache first (Optimistic UI)
      await _loadFromLocalCache();

      // 2. Load the offline sync queue
      await _loadSyncQueue();

      // 3. If online, attempt to sync and subscribe to real-time updates
      if (isOnline) {
        await synchronize();
        _subscribeToRealtime();
      }
    } catch (e) {
      _errorMessage = 'Initialization warning: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Getters ---
  List<Todo> get todos => List.unmodifiable(_todos);
  List<SyncCommand> get syncQueue => List.unmodifiable(_syncQueue);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Combines simulated toggle and actual device state (mocked or real)
  bool get isOffline => _isOfflineSimulated;
  bool get isOnline => !isOffline;

  // --- Keys for Local Storage ---
  String get _cacheKey => 'cached_todos_${authRepository.userId ?? "guest"}';
  String get _queueKey => 'sync_queue_${authRepository.userId ?? "guest"}';

  // --- Connection Control ---
  void setOfflineMode(bool offline) {
    if (_isOfflineSimulated == offline) return;
    _isOfflineSimulated = offline;
    notifyListeners();

    if (isOnline && authRepository.isAuthenticated) {
      synchronize();
      _subscribeToRealtime();
    } else {
      _realtimeSubscription?.cancel();
      _realtimeSubscription = null;
    }
  }

  // --- Local Cache Persistence ---
  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final list = json.decode(raw) as List<dynamic>;
        _todos.clear();
        for (final item in list) {
          try {
            _todos.add(Todo.fromJson(Map<String, dynamic>.from(item as Map)));
          } catch (_) {}
        }
      } else {
        // Seed default items for first time local user
        _todos.clear();
        final now = DateTime.now();
        _todos.addAll([
          Todo(
            id: 'seed-1',
            userId: authRepository.userId,
            title: 'Welcome to your Workspace!',
            description: 'This is an offline-first todo app. Try adding a task.',
            priority: Priority.high,
            category: 'Personal',
            dueDate: now.add(const Duration(days: 1)),
          ),
          Todo(
            id: 'seed-2',
            userId: authRepository.userId,
            title: 'Test Offline Synchronization',
            description: 'Toggle Offline Mode in settings, make changes, and toggle back Online!',
            priority: Priority.medium,
            category: 'Study',
            dueDate: now.add(const Duration(days: 3)),
          ),
        ]);
        await _saveToLocalCache();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading local cache: $e');
    }
  }

  Future<void> _saveToLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = json.encode(_todos.map((t) => t.toJson()).toList());
      await prefs.setString(_cacheKey, raw);
    } catch (e) {
      if (kDebugMode) print('Error saving local cache: $e');
    }
  }

  // --- Sync Queue Persistence ---
  Future<void> _loadSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_queueKey);
      if (raw != null) {
        final list = json.decode(raw) as List<dynamic>;
        _syncQueue.clear();
        for (final item in list) {
          try {
            _syncQueue.add(SyncCommand.fromJson(Map<String, dynamic>.from(item as Map)));
          } catch (_) {}
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading sync queue: $e');
    }
  }

  Future<void> _saveSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = json.encode(_syncQueue.map((c) => c.toJson()).toList());
      await prefs.setString(_queueKey, raw);
    } catch (e) {
      if (kDebugMode) print('Error saving sync queue: $e');
    }
  }

  // --- Optimistic CRUD Operations ---

  void addTodo(Todo todo) {
    if (!authRepository.isAuthenticated) return;
    final finalTodo = todo.userId == null ? todo.copyWith(userId: authRepository.userId) : todo;

    // 1. Optimistic Update Local State
    _todos.add(finalTodo);
    _saveToLocalCache();
    notifyListeners();

    // 2. Perform Backend sync or queue
    if (isOnline) {
      SupabaseService.instance.createTodo(finalTodo).catchError((error) {
        // Network fail: add to queue
        _queueAction(SyncAction.insert, finalTodo);
      });
    } else {
      _queueAction(SyncAction.insert, finalTodo);
    }
  }

  void updateTodo(Todo todo) {
    if (!authRepository.isAuthenticated) return;

    // 1. Optimistic Update Local State
    final idx = _todos.indexWhere((t) => t.id == todo.id);
    if (idx != -1) {
      _todos[idx] = todo;
      _saveToLocalCache();
      notifyListeners();
    }

    // 2. Perform Backend sync or queue
    if (isOnline) {
      SupabaseService.instance.updateTodo(todo).catchError((error) {
        _queueAction(SyncAction.update, todo);
      });
    } else {
      _queueAction(SyncAction.update, todo);
    }
  }

  void deleteTodo(String id) {
    if (!authRepository.isAuthenticated) return;

    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final deletedTodo = _todos[idx];

    // 1. Optimistic Update Local State
    _todos.removeAt(idx);
    _saveToLocalCache();
    notifyListeners();

    // 2. Perform Backend sync or queue
    if (isOnline) {
      SupabaseService.instance.deleteTodo(id).catchError((error) {
        _queueAction(SyncAction.delete, deletedTodo);
      });
    } else {
      _queueAction(SyncAction.delete, deletedTodo);
    }
  }

  void toggleComplete(String id, bool completed) {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final updated = _todos[idx].copyWith(
        completed: completed,
        updatedAt: DateTime.now(),
      );
      updateTodo(updated);
    }
  }

  void _queueAction(SyncAction action, Todo todo) {
    // Optimization: if there's already a command in the queue for this Todo, merge/replace it
    final existingIdx = _syncQueue.indexWhere((c) => c.todo.id == todo.id);
    
    if (existingIdx != -1) {
      final existingAction = _syncQueue[existingIdx].action;
      if (existingAction == SyncAction.insert && action == SyncAction.delete) {
        // Insert followed by delete: simply remove the insert command
        _syncQueue.removeAt(existingIdx);
      } else if (existingAction == SyncAction.insert && action == SyncAction.update) {
        // Insert followed by update: replace the insert with update containing latest fields but KEEP insert type
        _syncQueue[existingIdx] = SyncCommand(
          id: _syncQueue[existingIdx].id,
          action: SyncAction.insert,
          todo: todo,
        );
      } else {
        // General replace
        _syncQueue[existingIdx] = SyncCommand(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          action: action,
          todo: todo,
        );
      }
    } else {
      _syncQueue.add(SyncCommand(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        action: action,
        todo: todo,
      ));
    }
    _saveSyncQueue();
    notifyListeners();
  }

  // --- Synchronization Engine & Playback ---

  Future<void> synchronize() async {
    if (isOffline || !authRepository.isAuthenticated) return;

    _errorMessage = null;
    
    // 1. Replay queued commands in chronological order
    if (_syncQueue.isNotEmpty) {
      final List<SyncCommand> failedCommands = [];
      
      for (final command in _syncQueue) {
        try {
          switch (command.action) {
            case SyncAction.insert:
              await SupabaseService.instance.createTodo(command.todo);
              break;
            case SyncAction.update:
              await SupabaseService.instance.updateTodo(command.todo);
              break;
            case SyncAction.delete:
              await SupabaseService.instance.deleteTodo(command.todo.id);
              break;
          }
        } catch (e) {
          // If network error, stop playback to keep ordering. Otherwise, log failure and skip.
          if (e.toString().contains('network') || e.toString().contains('Failed host')) {
            failedCommands.addAll(_syncQueue.sublist(_syncQueue.indexOf(command)));
            _errorMessage = 'Synchronization suspended: network connection interrupted.';
            break;
          } else {
            // Other database constraints or RLS failures: log and discard
            if (kDebugMode) print('Discarding sync command due to persistent failure: $e');
          }
        }
      }

      _syncQueue.clear();
      _syncQueue.addAll(failedCommands);
      await _saveSyncQueue();
      notifyListeners();
    }

    // 2. Fetch the latest list from server to merge updates (incorporates other devices)
    try {
      final remoteTodos = await SupabaseService.instance.fetchTodos();
      _mergeRemoteTodos(remoteTodos);
    } catch (e) {
      if (kDebugMode) print('Failed to fetch remote todos: $e');
      if (_errorMessage == null) {
        _errorMessage = 'Sync warning: Fetching latest database entries failed.';
      }
    }
  }

  void _mergeRemoteTodos(List<Todo> remoteTodos) {
    // Track todos with pending local edits to prevent overriding them with stale remote versions
    final pendingIds = _syncQueue.map((c) => c.todo.id).toSet();

    for (final remote in remoteTodos) {
      if (pendingIds.contains(remote.id)) {
        // Skip updating local record if there's a pending offline write.
        // It will resolve on next sync cycle.
        continue;
      }

      final localIdx = _todos.indexWhere((t) => t.id == remote.id);
      if (localIdx != -1) {
        // Last-Write-Wins Conflict Resolution
        final local = _todos[localIdx];
        if (remote.updatedAt.isAfter(local.updatedAt)) {
          _todos[localIdx] = remote;
        }
      } else {
        // Insert remote item locally
        _todos.add(remote);
      }
    }

    // Remove local items that are not in remote, unless they were created offline and are still pending sync
    final remoteIds = remoteTodos.map((t) => t.id).toSet();
    _todos.removeWhere((local) {
      return !remoteIds.contains(local.id) && !pendingIds.contains(local.id);
    });

    _saveToLocalCache();
    notifyListeners();
  }

  // --- Real-time Streaming Sync ---

  void _subscribeToRealtime() {
    if (_realtimeSubscription != null || isOffline || !authRepository.isAuthenticated) return;

    _realtimeSubscription = SupabaseService.instance.todosStream.listen((remoteList) {
      _mergeRemoteTodos(remoteList);
    }, onError: (e) {
      if (kDebugMode) print('Realtime stream error: $e');
    });
  }

  /// Triggered from Settings/Dashboard to simulate a second device change
  Future<void> simulateSecondDeviceUpdate(Todo todo) async {
    if (SupabaseService.useMock) {
      final mock = SupabaseService.instance as MockSupabaseService;
      await mock.simulateRemoteChange(todo);
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    authRepository.removeListener(_onAuthChanged);
    super.dispose();
  }
}
