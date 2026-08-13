import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/screens/todos/todo_dashboard.dart';
import 'package:todo_app/services/supabase_service.dart';
import 'package:todo_app/repositories/auth_repository.dart';
import 'package:todo_app/state/todo_providers.dart';

void main() {
  testWidgets('Dashboard UI renders list and header elements', (WidgetTester tester) async {
    // 1. Setup mock storage and mock Supabase
    SharedPreferences.setMockInitialValues({});
    await SupabaseService.initialize(url: '', anonKey: '');

    // 2. Set screen size to prevent layout bounds issues in tests
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final guestAuthRepo = AuthRepository();
    guestAuthRepo.setGuestMode(true);

    // 3. Pump dashboard widget wrapped in Riverpod ProviderScope
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

    await tester.pumpAndSettle();

    // 4. Verify core UI elements exist
    expect(find.text('TaskCraft'), findsOneWidget);
    expect(find.text('Add Task'), findsWidgets);
  });
}
