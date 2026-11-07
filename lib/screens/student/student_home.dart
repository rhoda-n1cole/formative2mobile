import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../shared/incident_list_view.dart';
import 'submit_report_screen.dart';

class StudentHome extends ConsumerStatefulWidget {
  const StudentHome({super.key});

  @override
  ConsumerState<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends ConsumerState<StudentHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(appUserProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'All reports' : 'My reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: _tab == 0
          ? const IncidentListView()
          : IncidentListView(onlyMineFor: me?.uid),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Report'),
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SubmitReportScreen())),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'All'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Mine',
          ),
        ],
      ),
    );
  }
}
