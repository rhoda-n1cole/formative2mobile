import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';

class StudentHome extends ConsumerWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Center(child: Text('Welcome, ${user?.name ?? ''} (student)')),
    );
  }
}
