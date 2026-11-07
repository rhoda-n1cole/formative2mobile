import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants.dart';
import '../../models/incident.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/incident_card.dart';
import 'incident_details_screen.dart';

class IncidentListView extends ConsumerWidget {
  const IncidentListView({super.key, this.onlyMineFor});

  /// When set, only incidents reported by this uid are shown.
  final String? onlyMineFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final async = ref.watch(filteredIncidentsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search reports',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => ref
                .read(filterProvider.notifier)
                .set(filter.copyWith(query: v)),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _FilterDropdown(
                hint: 'Category',
                value: filter.category,
                options: AppConstants.categories,
                onChanged: (v) => ref
                    .read(filterProvider.notifier)
                    .set(filter.copyWith(category: v)),
              ),
              const SizedBox(width: 8),
              _FilterDropdown(
                hint: 'Status',
                value: filter.status,
                options: AppConstants.statuses,
                onChanged: (v) => ref
                    .read(filterProvider.notifier)
                    .set(filter.copyWith(status: v)),
              ),
            ],
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Could not load reports: $e')),
            data: (all) {
              final list = onlyMineFor == null
                  ? all
                  : all.where((i) => i.reporterId == onlyMineFor).toList();
              if (list.isEmpty) {
                return const Center(child: Text('No reports found'));
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => IncidentCard(
                  incident: list[i],
                  onTap: () => _open(context, list[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, Incident i) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncidentDetailsScreen(incidentId: i.id),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: onChanged,
      itemBuilder: (_) => [
        const PopupMenuItem<String?>(value: null, child: Text('All')),
        ...options.map((o) => PopupMenuItem<String?>(value: o, child: Text(o))),
      ],
      child: Chip(
        label: Text(value ?? hint),
        avatar: const Icon(Icons.filter_list, size: 16),
        backgroundColor: value != null
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
    );
  }
}
