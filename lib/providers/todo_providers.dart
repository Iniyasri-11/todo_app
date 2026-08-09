import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../repositories/todo_repository.dart';
import '../services/todo_api_service.dart';

final todoRepositoryProvider = ChangeNotifierProvider<TodoRepository>((ref) {
  final service = AppConfig.enableRemoteSync
      ? TodoApiService(baseUrl: AppConfig.todoApiBaseUrl)
      : null;

  return TodoRepository(apiService: service, syncWithRemote: AppConfig.enableRemoteSync);
});
