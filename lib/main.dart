import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/auth_page.dart';
import 'screens/todos/todo_dashboard.dart';

void main() {
  runApp(const ProviderScope(child: TodoApp()));
}

/// Root of the application. Uses the centralized [AppTheme].
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Management App',
      theme: AppTheme.lightTheme,
      home: const TodoDashboard(),
      routes: {
        '/dashboard': (context) => const TodoDashboard(),
        '/auth': (context) => const AuthPage(),
      },
    );
  }
}