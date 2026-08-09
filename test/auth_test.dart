import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/repositories/auth_repository.dart';
import 'package:todo_app/services/supabase_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SupabaseService.initialize(url: '', anonKey: '');
  });

  test('AuthRepository register and login flow', () async {
    final authRepo = AuthRepository();
    expect(authRepo.isAuthenticated, isFalse);

    // Register a new user
    final regSuccess = await authRepo.register('test@gmail.com', 'securepass123');
    expect(regSuccess, isTrue);
    expect(authRepo.isAuthenticated, isTrue);
    expect(authRepo.userEmail, 'test@gmail.com');
    final userId = authRepo.userId;

    // Logout
    await authRepo.logout();
    expect(authRepo.isAuthenticated, isFalse);
    expect(authRepo.userId, isNull);

    // Login back
    final loginSuccess = await authRepo.login('test@gmail.com', 'securepass123');
    expect(loginSuccess, isTrue);
    expect(authRepo.isAuthenticated, isTrue);
    expect(authRepo.userId, userId);
  });

  test('AuthRepository login invalid password fails', () async {
    final authRepo = AuthRepository();
    
    // Register
    await authRepo.register('wrong@gmail.com', 'securepass123');
    await authRepo.logout();

    // Login with bad password
    final loginSuccess = await authRepo.login('wrong@gmail.com', 'wrongpassword');
    expect(loginSuccess, isFalse);
    expect(authRepo.isAuthenticated, isFalse);
    expect(authRepo.errorMessage, isNotNull);
  });
}
