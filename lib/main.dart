import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/auth_page.dart';
import 'screens/todos/todo_dashboard.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final storedUrl = prefs.getString('admin_supabase_url');
  final storedKey = prefs.getString('admin_supabase_key');
  
  final url = storedUrl ?? 'https://wnnndfwgtezpycvtager.supabase.co';
  final key = storedKey ?? 'sb_publishable_ObqvM-GbY5BL5rBDx_WSeQ_oobE9RDz';

  await SupabaseService.initialize(
    url: url,
    anonKey: key,
  );
  runApp(const ProviderScope(child: TodoApp()));
}

/// Root of the application. Uses the centralized [AppTheme].
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskCraft',
      theme: AppTheme.lightTheme,
      home: const AuthPage(),
      routes: {
        '/dashboard': (context) => const TodoDashboard(),
        '/auth': (context) => const AuthPage(),
      },
    );
  }
}