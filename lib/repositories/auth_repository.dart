import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

/// Repository managing user session, registration, login, and logout.
/// Implements [ChangeNotifier] to update UI reactively.
class AuthRepository extends ChangeNotifier {
  String? _userId;
  String? _userEmail;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<String?>? _authSubscription;

  AuthRepository() {
    _init();
  }

  void _init() {
    _userId = SupabaseService.instance.currentUserId;
    _userEmail = SupabaseService.instance.currentUserEmail;

    // Listen to changes in the active service session
    _authSubscription = SupabaseService.instance.authStateChanges.listen((userId) {
      _userId = userId;
      _userEmail = SupabaseService.instance.currentUserEmail;
      _errorMessage = null;
      notifyListeners();
    });
  }

  String? get userId => _userId;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userId != null;

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    try {
      final uid = await SupabaseService.instance.signUp(email, password);
      _userId = uid;
      _userEmail = email;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final uid = await SupabaseService.instance.signIn(email, password);
      _userId = uid;
      _userEmail = email;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await SupabaseService.instance.signOut();
      _userId = null;
      _userEmail = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await SupabaseService.instance.resetPassword(email);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  /// Called when the active Supabase service instance changes (e.g. settings changed).
  void handleServiceChanged() {
    _authSubscription?.cancel();
    _init();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
