import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/staff/staff_home.dart';
import '../screens/student/student_home.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return auth.when(
      loading: () => const _Splash(),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) return const LoginScreen();
        if (!user.emailVerified) return const VerifyEmailScreen();

        final profile = ref.watch(appUserProvider);
        return profile.when(
          loading: () => const _Splash(),
          error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
          data: (p) {
            if (p == null) return const _Splash();
            return p.isStaff ? const StaffHome() : const StudentHome();
          },
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
