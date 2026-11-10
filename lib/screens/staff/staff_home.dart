import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants.dart';
import '../../app/theme.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/app_header.dart';
import '../shared/incident_list_view.dart';

class StaffHome extends ConsumerWidget {
  const StaffHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(incidentsProvider).value ?? [];
    final filter = ref.watch(filterProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Staff dashboard',
            subtitle: 'Review reports. Update progress.',
            onLogout: () => ref.read(authRepositoryProvider).signOut(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
            child: Row(
              children: AppConstants.statuses.map((s) {
                final n = all.where((i) => i.status == s).length;
                final color = AppColors.forStatus(s);
                final selected = filter.status == s;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => ref
                          .read(filterProvider.notifier)
                          .set(filter.copyWith(status: selected ? null : s)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(alpha: 0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? color : AppColors.border,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$n',
                              style: text.headlineSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s,
                              textAlign: TextAlign.center,
                              style: text.labelSmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          const Expanded(child: IncidentListView()),
        ],
      ),
    );
  }
}
