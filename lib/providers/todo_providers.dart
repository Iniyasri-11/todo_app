import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../repositories/todo_repository.dart';

/// Provider exposing the central [AuthRepository] instance.
final authRepositoryProvider = ChangeNotifierProvider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider exposing the offline-first [TodoRepository] instance,
/// bound to the authentication state.
final todoRepositoryProvider = ChangeNotifierProvider<TodoRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return TodoRepository(authRepository: authRepo);
});
