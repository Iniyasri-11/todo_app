import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase integration scaffolding. Set `SUPABASE_URL` and `SUPABASE_ANON_KEY`
/// via environment or directly when calling `SupabaseService.initialize`.
class SupabaseService {
  static bool _initialized = false;

  static Future<void> initialize({required String url, required String anonKey}) async {
    if (_initialized) return;
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authCallbackUrlHostname: 'login-callback',
    );
    _initialized = true;
  }

  static SupabaseClient get client {
    if (!_initialized) throw Exception('Supabase not initialized');
    return Supabase.instance.client;
  }
}
