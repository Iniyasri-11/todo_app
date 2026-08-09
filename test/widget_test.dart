import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/screens/todos/todo_dashboard.dart';

void main() {
  testWidgets('Dashboard shows Add Todo button', (WidgetTester tester) async {
    // initialize prefs with empty todos so list is empty (avoids layout overflow)
    SharedPreferences.setMockInitialValues({'todos_v1': '[]'});

    // provide larger surface so responsive layout doesn't overflow in test
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: TodoDashboard())));

    await tester.pumpAndSettle();

    expect(find.text('Add Task'), findsWidgets);
  });
}
