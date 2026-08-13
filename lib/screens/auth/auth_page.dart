import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/supabase_service.dart';
import '../../state/todo_providers.dart';

enum AuthMode { login, register, reset }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  
  AuthMode _mode = AuthMode.login;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(authRepositoryProvider).isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode newMode) {
    setState(() {
      _mode = newMode;
    });
    ref.read(authRepositoryProvider).clearError();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authRepo = ref.read(authRepositoryProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool success = false;
    
    if (_mode == AuthMode.login) {
      success = await authRepo.login(email, password);
    } else if (_mode == AuthMode.register) {
      success = await authRepo.register(email, password);
    } else if (_mode == AuthMode.reset) {
      success = await authRepo.resetPassword(email);
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent (simulated).')),
        );
        _switchMode(AuthMode.login);
      }
    }

    if (success && _mode != AuthMode.reset) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authRepositoryProvider);
    final theme = Theme.of(context);

    // If already logged in, show session info screen
    if (authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Session'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, size: 48, color: theme.colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Welcome Back!',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Logged in as:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${authState.userEmail}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID: ${authState.userId}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                            child: const Text('Dashboard'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: () => authState.logout(),
                            child: const Text('Sign Out'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.12),
              theme.colorScheme.secondary.withOpacity(0.08),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _mode == AuthMode.login
                              ? 'Welcome Back'
                              : _mode == AuthMode.register
                                  ? 'Create Account'
                                  : 'Reset Password',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _mode == AuthMode.login
                              ? 'Sign in to access your synchronized todos.'
                              : _mode == AuthMode.register
                                  ? 'Get started with a secure, sync-enabled workspace.'
                                  : 'Enter your email to reset your account password.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // Error Banner
                        if (authState.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    authState.errorMessage!,
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onErrorContainer),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        if (_mode != AuthMode.reset) ...[
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              if (v.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Confirm Password Field (Register Only)
                        if (_mode == AuthMode.register) ...[
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: Icon(Icons.lock_clock),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Confirm your password';
                              if (v != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Action Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: authState.isLoading ? null : _submit,
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  _mode == AuthMode.login
                                      ? 'Sign In'
                                      : _mode == AuthMode.register
                                          ? 'Sign Up'
                                          : 'Send Instructions',
                                ),
                        ),
                        const SizedBox(height: 20),

                        // Toggle Options
                        if (_mode == AuthMode.login) ...[
                          TextButton(
                            onPressed: () => _switchMode(AuthMode.reset),
                            child: const Text('Forgot Password?'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () => _switchMode(AuthMode.register),
                                child: const Text('Sign Up'),
                              ),
                            ],
                          ),
                        ] else if (_mode == AuthMode.register) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?'),
                              TextButton(
                                onPressed: () => _switchMode(AuthMode.login),
                                child: const Text('Sign In'),
                              ),
                            ],
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: () => _switchMode(AuthMode.login),
                            child: const Text('Back to Sign In'),
                          ),
                        ],

                        const Divider(height: 32),
                        
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: () {
                            ref.read(authRepositoryProvider).setGuestMode(true);
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          },
                          child: const Text('Continue as Guest'),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                          label: const Text('Admin Database Settings'),
                          onPressed: _showAdminAuthDialog,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAdminAuthDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Admin Authentication'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Admin Password',
              hintText: 'Enter admin password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final password = passwordController.text;
                Navigator.pop(context);
                if (password == 'admin') {
                  _showSupabaseConfigDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid admin credentials.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Authenticate'),
            ),
          ],
        );
      },
    );
  }

  void _showSupabaseConfigDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUrl = prefs.getString('admin_supabase_url') ?? 'https://wnnndfwgtezpycvtager.supabase.co';
    final currentKey = prefs.getString('admin_supabase_key') ?? 'sb_publishable_ObqvM-GbY5BL5rBDx_WSeQ_oobE9RDz';

    final urlController = TextEditingController(text: currentUrl == 'https://wnnndfwgtezpycvtager.supabase.co' ? '' : currentUrl);
    final keyController = TextEditingController(text: currentKey == 'sb_publishable_ObqvM-GbY5BL5rBDx_WSeQ_oobE9RDz' ? '' : currentKey);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supabase Configuration'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Configure the remote database connection details for this application instance.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Supabase URL',
                    hintText: 'https://xxx.supabase.co',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(
                    labelText: 'Anon API Key',
                    hintText: 'sb_publishable_xxx',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = urlController.text.trim();
                final key = keyController.text.trim();

                if (url.isEmpty || key.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Both URL and Key are required.')),
                  );
                  return;
                }

                try {
                  // Save to SharedPreferences
                  final p = await SharedPreferences.getInstance();
                  await p.setString('admin_supabase_url', url);
                  await p.setString('admin_supabase_key', key);

                  // Dynamically re-initialize SupabaseService
                  await SupabaseService.initialize(url: url, anonKey: key);
                  
                  // Reset repositories state
                  ref.read(authRepositoryProvider).handleServiceChanged();

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Connected to new Supabase instance successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Connection failed: $e')),
                  );
                }
              },
              child: const Text('Save and Connect'),
            ),
          ],
        );
      },
    );
  }
}
