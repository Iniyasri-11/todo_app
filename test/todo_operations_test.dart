import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/screens/todos/todo_dashboard.dart';
import 'package:todo_app/services/supabase_service.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/repositories/auth_repository.dart';
import 'package:todo_app/state/todo_providers.dart';

void main() {
  late AuthRepository authRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SupabaseService.initialize(url: '', anonKey: '');
    authRepo = AuthRepository();
    await authRepo.register('developer@example.com', 'mypassword');

    // Pre-seed mock Supabase database so synchronization retrieves these items
    final userId = authRepo.userId;
    final now = DateTime.now();
    await SupabaseService.instance.createTodo(Todo(
      id: 'seed-1',
      userId: userId,
      title: 'Welcome to your Workspace!',
      description: 'This is an offline-first todo app. Try adding a task.',
      priority: Priority.high,
      category: 'Personal',
      dueDate: now.add(const Duration(days: 1)),
    ));
    await SupabaseService.instance.createTodo(Todo(
      id: 'seed-2',
      userId: userId,
      title: 'Test Offline Synchronization',
      description: 'Toggle Offline Mode in settings, make changes, and toggle back Online!',
      priority: Priority.medium,
      category: 'Study',
      dueDate: now.add(const Duration(days: 3)),
    ));
  });

  testWidgets('Todo creation and validation flow', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => authRepo),
        ],
        child: const MaterialApp(
          home: TodoDashboard(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify seed tasks are displayed on start
    expect(find.text('Welcome to your Workspace!'), findsOneWidget);

    // Tap on Add Task button
    final addTaskButton = find.widgetWithText(FilledButton, 'Add Task');
    expect(addTaskButton, findsOneWidget);
    await tester.tap(addTaskButton);
    await tester.pumpAndSettle();

    // Verify Add New Todo dialog is displayed
    expect(find.text('Add New Todo'), findsOneWidget);

    // Click Save directly to trigger empty title validation
    final saveButton = find.text('Save');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(find.text('Title is required'), findsOneWidget);

    // Enter a very short title (under 3 chars)
    final titleField = find.widgetWithText(TextFormField, 'Title');
    await tester.enterText(titleField, 'Go');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(find.text('Title must be at least 3 characters'), findsOneWidget);

    // Enter a valid title and save
    await tester.enterText(titleField, 'Prepare launch presentation');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify dialog closes and task is rendered on the dashboard
    expect(find.text('Add New Todo'), findsNothing);
    expect(find.text('Prepare launch presentation'), findsOneWidget);
  });

  testWidgets('Todo completion and list filtering', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => authRepo),
        ],
        child: const MaterialApp(
          home: TodoDashboard(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify base seed tasks
    expect(find.text('Welcome to your Workspace!'), findsOneWidget); // High priority
    expect(find.text('Test Offline Synchronization'), findsOneWidget); // Medium priority

    // 1. Test Priority Filter Chips
    final highChip = find.widgetWithText(ChoiceChip, 'High Priority');
    final mediumChip = find.widgetWithText(ChoiceChip, 'Medium Priority');

    await tester.tap(highChip);
    await tester.pumpAndSettle();
    expect(find.text('Welcome to your Workspace!'), findsOneWidget);
    expect(find.text('Test Offline Synchronization'), findsNothing);

    await tester.tap(mediumChip);
    await tester.pumpAndSettle();
    expect(find.text('Welcome to your Workspace!'), findsNothing);
    expect(find.text('Test Offline Synchronization'), findsOneWidget);

    // Reset filter to All
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();

    // 2. Test Task Completion Flow
    // Find checkboxes. Seed-1 is the first card.
    final firstCheckbox = find.byType(Checkbox).first;
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    // Filter by Completed
    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to your Workspace!'), findsOneWidget);
    expect(find.text('Test Offline Synchronization'), findsNothing);

    // Filter by Pending
    await tester.tap(find.widgetWithText(ChoiceChip, 'Pending'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to your Workspace!'), findsNothing);
    expect(find.text('Test Offline Synchronization'), findsOneWidget);
  });

  testWidgets('Todo search functionality', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => authRepo),
        ],
        child: const MaterialApp(
          home: TodoDashboard(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    final searchField = find.widgetWithText(TextField, 'Search tasks...');
    expect(searchField, findsOneWidget);

    // Search for "Workspace"
    await tester.enterText(searchField, 'Workspace');
    await tester.pumpAndSettle();
    expect(find.text('Welcome to your Workspace!'), findsOneWidget);
    expect(find.text('Test Offline Synchronization'), findsNothing);

    // Search for non-existent keyword to check empty state
    await tester.enterText(searchField, 'UnknownTaskXYZ');
    await tester.pumpAndSettle();
    expect(find.text('Welcome to your Workspace!'), findsNothing);
    expect(find.text('No tasks match search criteria'), findsOneWidget);
  });

  testWidgets('Todo delete confirmation and deletion', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => authRepo),
        ],
        child: const MaterialApp(
          home: TodoDashboard(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify task is present
    expect(find.text('Welcome to your Workspace!'), findsOneWidget);

    // Find and tap the delete icon on the first task card
    final deleteIcon = find.byIcon(Icons.delete_outline).first;
    await tester.tap(deleteIcon);
    await tester.pumpAndSettle();

    // Verify custom polished Delete Task dialog opens
    expect(find.text('Delete Task?'), findsOneWidget);

    // Tap Cancel
    final cancelButton = find.widgetWithText(OutlinedButton, 'Cancel');
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    // Verify dialog closed and task is still present
    expect(find.text('Delete Task?'), findsNothing);
    expect(find.text('Welcome to your Workspace!'), findsOneWidget);

    // Tap Delete icon again, and select Delete inside the dialog
    await tester.tap(deleteIcon);
    await tester.pumpAndSettle();
    final deleteConfirmButton = find.widgetWithText(ElevatedButton, 'Delete');
    await tester.tap(deleteConfirmButton);
    await tester.pumpAndSettle();

    // Verify task is removed from UI list
    expect(find.text('Welcome to your Workspace!'), findsNothing);
  });

  testWidgets('Guest user can add todo locally in guest workspace', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final guestAuthRepo = MockGuestAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => guestAuthRepo),
        ],
        child: const MaterialApp(
          home: TodoDashboard(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify Guest Profile header tag is displayed in AppBar
    expect(find.text('Guest Profile'), findsOneWidget);

    // Tap on Add Task button
    final addTaskButton = find.widgetWithText(FilledButton, 'Add Task');
    expect(addTaskButton, findsOneWidget);
    await tester.tap(addTaskButton);
    await tester.pumpAndSettle();

    // Verify Add New Todo dialog is displayed
    expect(find.text('Add New Todo'), findsOneWidget);

    // Enter a valid title and save
    final titleField = find.widgetWithText(TextFormField, 'Title');
    await tester.enterText(titleField, 'Guest local test task');
    
    final saveButton = find.text('Save');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify dialog closes and task is rendered on the dashboard locally
    expect(find.text('Add New Todo'), findsNothing);
    expect(find.text('Guest local test task'), findsOneWidget);
  });
}

class MockGuestAuthRepository extends AuthRepository {
  @override
  bool get isAuthenticated => false;

  @override
  bool get isGuestMode => true;

  @override
  String? get userEmail => null;

  @override
  String? get userId => null;
}
