import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../shared/incident_details_screen.dart';
import '../shared/incident_list_view.dart';
import 'submit_report_screen.dart';

class StudentHome extends ConsumerStatefulWidget {
  const StudentHome({super.key});

  @override
  ConsumerState<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends ConsumerState<StudentHome> {
  int _tab = 0;

  void _report() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SubmitReportScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(appUserProvider).value;

    final Widget body;
    switch (_tab) {
      case 1:
        body = _TitledTab(
          title: 'All reports',
          child: const IncidentListView(),
        );
        break;
      case 2:
        body = _TitledTab(
          title: 'My reports',
          child: IncidentListView(onlyMineFor: me?.uid),
        );
        break;
      default:
        body = _HomeTab(
          onReport: _report,
          onSeeAll: () => setState(() => _tab = 1),
        );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Mine',
          ),
        ],
      ),
    );
  }
}

class _TitledTab extends StatelessWidget {
  const _TitledTab({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.onReport, required this.onSeeAll});
  final VoidCallback onReport;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(appUserProvider).value;
    final all = ref.watch(incidentsProvider).value ?? [];
    final mine = all.where((i) => i.reporterId == me?.uid).toList();
    final first = (me?.name ?? '').trim().split(' ').first;
    final text = Theme.of(context).textTheme;

    int count(String s) => mine.where((i) => i.status == s).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Greeting
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        first.isEmpty ? 'Hello 👋' : 'Hello, $first 👋',
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Help make our campus safer.',
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Report issues and track their resolution.',
                        style: text.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Log out',
                  icon: const Icon(Icons.logout),
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      first.isEmpty ? '?' : first[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B6BFF), AppColors.primaryDark],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -4,
                    top: 0,
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 110,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'See an issue\non campus?',
                        style: text.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Report it and help improve\nour learning environment.',
                        style: text.bodySmall?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: onReport,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: AppColors.primary,
                                  size: 26,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Report an Issue',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Report summary
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: Text(
              'Report Summary',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _SummaryTile(
                  icon: Icons.description_outlined,
                  color: AppColors.primary,
                  value: mine.length,
                  label: 'My Reports',
                ),
                _SummaryTile(
                  icon: Icons.schedule,
                  color: AppColors.inProgress,
                  value: count('In Progress'),
                  label: 'In Progress',
                ),
                _SummaryTile(
                  icon: Icons.check_circle_outline,
                  color: AppColors.resolved,
                  value: count('Resolved'),
                  label: 'Resolved',
                ),
                _SummaryTile(
                  icon: Icons.error_outline,
                  color: AppColors.danger,
                  value: count('Submitted'),
                  label: 'Submitted',
                ),
              ],
            ),
          ),

          // Recent reports
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Reports',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(onPressed: onSeeAll, child: const Text('See all')),
              ],
            ),
          ),
          if (all.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No reports yet',
                subtitle: 'Tap "Report an Issue" to submit the first one.',
              ),
            )
          else
            ...all
                .take(5)
                .map(
                  (i) => IncidentCard(
                    incident: i,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => IncidentDetailsScreen(incidentId: i.id),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
