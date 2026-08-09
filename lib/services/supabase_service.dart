import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo.dart';

/// Common interface for Supabase capabilities.
abstract class BaseSupabaseService {
  // Authentication
  Future<String?> signUp(String email, String password);
  Future<String?> signIn(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  String? get currentUserId;
  String? get currentUserEmail;
  Stream<String?> get authStateChanges;

  // Database CRUD
  Future<List<Todo>> fetchTodos();
  Future<Todo> createTodo(Todo todo);
  Future<Todo> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);

  // Real-time synchronization
  Stream<List<Todo>> get todosStream;
}

/// Central manager that toggles between Real and Mock Supabase service instances.
class SupabaseService {
  static bool _initialized = false;
  static bool _useMock = true;
  static late BaseSupabaseService _instance;

  static bool get useMock => _useMock;
  static BaseSupabaseService get instance {
    if (!_initialized) throw Exception('SupabaseService not initialized. Call initialize() first.');
    return _instance;
  }

  static Future<void> initialize({required String url, required String anonKey}) async {
    if (_initialized) return;

    final isUrlPlaceholder = url.isEmpty || url == '<URL>' || url.contains('example.com');
    final isKeyPlaceholder = anonKey.isEmpty || anonKey == '<ANON_KEY>';

    if (!isUrlPlaceholder && !isKeyPlaceholder) {
      try {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
          authCallbackUrlHostname: 'login-callback',
        );
        _instance = RealSupabaseService();
        _useMock = false;
      } catch (e) {
        if (kDebugMode) print('Failed to initialize Real Supabase: $e. Falling back to Mock.');
        _instance = MockSupabaseService();
        _useMock = true;
      }
    } else {
      _instance = MockSupabaseService();
      _useMock = true;
    }
    _initialized = true;
  }

  // Allow dynamic swapping for manual configuration in Settings
  static void setInstance(BaseSupabaseService customInstance, {required bool mock}) {
    _instance = customInstance;
    _useMock = mock;
    _initialized = true;
  }
}

/// 1. Real implementation using the official Supabase Flutter SDK
class RealSupabaseService implements BaseSupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final StreamController<String?> _authStreamController = StreamController<String?>.broadcast();

  RealSupabaseService() {
    _client.auth.onAuthStateChange.listen((data) {
      _authStreamController.add(data.session?.user.id);
    });
  }

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  String? get currentUserEmail => _client.auth.currentUser?.email;

  @override
  Stream<String?> get authStateChanges => _authStreamController.stream;

  @override
  Future<String?> signUp(String email, String password) async {
    final res = await _client.auth.signUp(email: email, password: password);
    return res.user?.id;
  }

  @override
  Future<String?> signIn(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    return res.user?.id;
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<List<Todo>> fetchTodos() async {
    final res = await _client
        .from('todos')
        .select()
        .order('created_at', ascending: true);
    final list = res as List<dynamic>;
    return list.map((e) => Todo.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<Todo> createTodo(Todo todo) async {
    final res = await _client
        .from('todos')
        .insert(todo.toJson())
        .select()
        .single();
    return Todo.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    final res = await _client
        .from('todos')
        .update(todo.toJson())
        .eq('id', todo.id)
        .select()
        .single();
    return Todo.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _client.from('todos').delete().eq('id', id);
  }

  @override
  Stream<List<Todo>> get todosStream {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);
    return _client
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: true)
        .map((list) => list.map((e) => Todo.fromJson(e)).toList());
  }
}

/// 2. Mock simulation using SharedPreferences for persistence and latency simulation
class MockSupabaseService implements BaseSupabaseService {
  final StreamController<String?> _authStreamController = StreamController<String?>.broadcast();
  final StreamController<List<Todo>> _todosStreamController = StreamController<List<Todo>>.broadcast();

  String? _currentUserId;
  String? _currentUserEmail;

  static const String _usersKey = 'mock_auth_users';
  static const String _sessionUserKey = 'mock_session_userid';
  static const String _sessionEmailKey = 'mock_session_email';
  static const String _dbTodosKey = 'mock_supabase_db_todos';

  MockSupabaseService() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString(_sessionUserKey);
    _currentUserEmail = prefs.getString(_sessionEmailKey);
    _authStreamController.add(_currentUserId);
    _triggerStreamUpdate();
  }

  Future<void> _saveSession(String? userId, String? email) async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = userId;
    _currentUserEmail = email;
    if (userId != null) {
      await prefs.setString(_sessionUserKey, userId);
      await prefs.setString(_sessionEmailKey, email ?? '');
    } else {
      await prefs.remove(_sessionUserKey);
      await prefs.remove(_sessionEmailKey);
    }
    _authStreamController.add(userId);
    _triggerStreamUpdate();
  }

  @override
  String? get currentUserId => _currentUserId;

  @override
  String? get currentUserEmail => _currentUserEmail;

  @override
  Stream<String?> get authStateChanges => _authStreamController.stream;

  @override
  Future<String?> signUp(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Network delay
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_usersKey) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersRaw) as Map<String, dynamic>;

    if (users.containsKey(email)) {
      throw Exception('User already exists');
    }

    final userId = 'mock-user-${DateTime.now().millisecondsSinceEpoch}';
    users[email] = {'password': password, 'id': userId};
    await prefs.setString(_usersKey, json.encode(users));

    await _saveSession(userId, email);
    return userId;
  }

  @override
  Future<String?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Network delay
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_usersKey) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersRaw) as Map<String, dynamic>;

    if (!users.containsKey(email) || users[email]['password'] != password) {
      throw Exception('Invalid email or password');
    }

    final userId = users[email]['id'] as String;
    await _saveSession(userId, email);
    return userId;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _saveSession(null, null);
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_usersKey) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersRaw) as Map<String, dynamic>;

    if (!users.containsKey(email)) {
      throw Exception('Email address not found');
    }
  }

  // --- Database CRUD Implementation ---

  Future<List<Todo>> _getAllTodosFromDb() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dbTodosKey) ?? '[]';
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => Todo.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> _saveAllTodosToDb(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(todos.map((t) => t.toJson()).toList());
    await prefs.setString(_dbTodosKey, raw);
  }

  Future<void> _triggerStreamUpdate() async {
    if (_currentUserId == null) {
      _todosStreamController.add([]);
      return;
    }
    final all = await _getAllTodosFromDb();
    // Multi-user isolation policy: filter by current user_id
    final filtered = all.where((t) => t.userId == _currentUserId).toList();
    _todosStreamController.add(filtered);
  }

  @override
  Future<List<Todo>> fetchTodos() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Network delay
    if (_currentUserId == null) throw Exception('Unauthorized access');
    final all = await _getAllTodosFromDb();
    return all.where((t) => t.userId == _currentUserId).toList();
  }

  @override
  Future<Todo> createTodo(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentUserId == null) throw Exception('Unauthorized access');

    final withUser = todo.userId == null ? todo.copyWith(userId: _currentUserId) : todo;
    final all = await _getAllTodosFromDb();
    
    // Check for duplicate to prevent conflict
    all.removeWhere((t) => t.id == withUser.id);
    all.add(withUser);
    await _saveAllTodosToDb(all);
    
    _triggerStreamUpdate();
    return withUser;
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentUserId == null) throw Exception('Unauthorized access');

    final all = await _getAllTodosFromDb();
    final idx = all.indexWhere((t) => t.id == todo.id);
    if (idx != -1) {
      all[idx] = todo;
    } else {
      all.add(todo);
    }
    await _saveAllTodosToDb(all);

    _triggerStreamUpdate();
    return todo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUserId == null) throw Exception('Unauthorized access');

    final all = await _getAllTodosFromDb();
    all.removeWhere((t) => t.id == id);
    await _saveAllTodosToDb(all);

    _triggerStreamUpdate();
  }

  @override
  Stream<List<Todo>> get todosStream {
    _triggerStreamUpdate();
    return _todosStreamController.stream;
  }

  /// Helper to trigger a simulated remote server modification (for testing Real-Time Sync)
  Future<void> simulateRemoteChange(Todo todo) async {
    final all = await _getAllTodosFromDb();
    all.removeWhere((t) => t.id == todo.id);
    all.add(todo);
    await _saveAllTodosToDb(all);
    _triggerStreamUpdate();
  }
}
