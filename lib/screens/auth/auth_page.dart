import 'package:flutter/material.dart';

/// Authentication landing page showing the available auth flows.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Authentication Flows',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  'Select an authentication screen to preview or implement.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                _AuthButton(
                  label: 'Registration',
                  description: 'User signup flow with validation.',
                  icon: Icons.person_add_alt_1,
                ),
                _AuthButton(
                  label: 'Login',
                  description: 'User login with email/password.',
                  icon: Icons.login,
                ),
                _AuthButton(
                  label: 'Logout',
                  description: 'Logout and clear session state.',
                  icon: Icons.logout,
                ),
                _AuthButton(
                  label: 'Session',
                  description: 'Session persistence and auto-login.',
                  icon: Icons.lock_clock,
                ),
                _AuthButton(
                  label: 'Password reset',
                  description: 'Reset your password via email.',
                  icon: Icons.lock_reset,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;

  const _AuthButton({
    required this.label,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {},
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
