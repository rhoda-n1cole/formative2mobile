import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../repositories/auth_repository.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Auto-check every 4 seconds so the user doesn't have to tap anything.
    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _check(silent: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check({bool silent = false}) async {
    if (_checking) return;
    _checking = true;
    final verified = await ref
        .read(authRepositoryProvider)
        .reloadAndCheckVerified();
    _checking = false;
    if (verified) {
      ref.invalidate(authStateProvider); // makes AuthGate rebuild
    } else if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not verified yet. Check your inbox.')),
      );
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authRepositoryProvider).resendVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent.')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authStateProvider).value?.email ?? '';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 72),
              const SizedBox(height: 16),
              Text(
                'Verify your email',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to\n$email\n\nOpen it, then come back here. Check your spam folder if you can\'t find it.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _check(),
                child: const Text("I've verified my email"),
              ),
              TextButton(onPressed: _resend, child: const Text('Resend email')),
              TextButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text('Use a different account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
