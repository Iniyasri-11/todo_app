import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/repositories/auth_repository.dart';
import 'package:todo_app/repositories/todo_repository.dart';
import 'package:todo_app/services/supabase_service.dart';

void main() {
  late AuthRepository authRepo;
  late TodoRepository todoRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SupabaseService.initialize(url: '', anonKey: '');
    authRepo = AuthRepository();
    // Authenticate user
    await authRepo.register('developer@example.com', 'mypassword');
    todoRepo = TodoRepository(authRepository: authRepo);
    // Allow initial load
    await Future.delayed(const Duration(milliseconds: 100));
  });

  test('Optimistic updates occur locally and queue writes when offline', () async {
    // 1. Set repository offline
    todoRepo.setOfflineMode(true);
    expect(todoRepo.isOffline, isTrue);

    // 2. Add a new todo optimistically
    final todo = Todo(
      id: 'test-off-1',
      title: 'Offline Task',
      description: 'Add while offline',
    );
    todoRepo.addTodo(todo);

    // Verify it is added to the local todo list immediately
    expect(todoRepo.todos.any((t) => t.id == 'test-off-1'), isTrue);
    // Verify it is queued in the sync queue
    expect(todoRepo.syncQueue.length, 1);
    expect(todoRepo.syncQueue.first.todo.id, 'test-off-1');

    // 3. Switch to online, which triggers auto-sync
    todoRepo.setOfflineMode(false);
    await Future.delayed(const Duration(milliseconds: 500)); // allow playback

    // Verify sync queue is now played back and empty
    expect(todoRepo.syncQueue, isEmpty);

    // Verify record exists in server database by fetching directly
    final serverTodos = await SupabaseService.instance.fetchTodos();
    expect(serverTodos.any((t) => t.id == 'test-off-1'), isTrue);
  });

  test('Last-Write-Wins conflict resolution retains newer records', () async {
    final now = DateTime.now();

    // Local todo version (older)
    final localTodo = Todo(
      id: 'conflict-1',
      userId: authRepo.userId,
      title: 'Stale Local Version',
      updatedAt: now.subtract(const Duration(minutes: 10)),
    );
    todoRepo.addTodo(localTodo);
    await Future.delayed(const Duration(milliseconds: 500)); // Sync to mock server

    // Remote change occurs on another device (newer)
    final remoteTodo = Todo(
      id: 'conflict-1',
      userId: authRepo.userId,
      title: 'Fresh Remote Version',
      updatedAt: now,
    );
    // Simulate other device pushing update directly to server db
    final mockService = SupabaseService.instance as MockSupabaseService;
    await mockService.simulateRemoteChange(remoteTodo);

    // Trigger sync on our client repo
    await todoRepo.synchronize();

    // Verify our local list is updated to the newer remote title
    final mergedTodo = todoRepo.todos.firstWhere((t) => t.id == 'conflict-1');
    expect(mergedTodo.title, 'Fresh Remote Version');
  });

  test('Multi-user data isolation isolates user cached todos', () async {
    // Add todo for developer@example.com
    final devTodo = Todo(id: 'dev-task', title: 'Developer Task');
    todoRepo.addTodo(devTodo);
    await Future.delayed(const Duration(milliseconds: 500));

    expect(todoRepo.todos.any((t) => t.id == 'dev-task'), isTrue);

    // Sign out developer
    await authRepo.logout();
    expect(todoRepo.todos, isEmpty);

    // Register a second user
    await authRepo.register('student@example.com', 'studentpass');
    // Allow reload
    await Future.delayed(const Duration(milliseconds: 200));

    // Verify student todo list does not contain developer todo
    expect(todoRepo.todos.any((t) => t.id == 'dev-task'), isFalse);

    // Add student todo
    final studentTodo = Todo(id: 'stud-task', title: 'Student Task');
    todoRepo.addTodo(studentTodo);
    await Future.delayed(const Duration(milliseconds: 500));

    expect(todoRepo.todos.any((t) => t.id == 'stud-task'), isTrue);
  });
}
