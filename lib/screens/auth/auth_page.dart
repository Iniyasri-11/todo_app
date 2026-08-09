import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/todo_providers.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent (simulated).')),
        );
        _switchMode(AuthMode.login);
      }
    }

    if (success && mounted && _mode != AuthMode.reset) {
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
                          onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                          child: const Text('Continue as Guest'),
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
}
