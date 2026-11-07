import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/constants.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/status_chip.dart';

class IncidentDetailsScreen extends ConsumerWidget {
  const IncidentDetailsScreen({super.key, required this.incidentId});
  final String incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentAsync = ref.watch(incidentProvider(incidentId));
    final historyAsync = ref.watch(historyProvider(incidentId));
    final me = ref.watch(appUserProvider).value;
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Report details')),
      body: incidentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (i) {
          if (i == null) return const Center(child: Text('Report not found'));
          final isOwner = me?.uid == i.reporterId;
          // Staff see the real name; anonymous stays hidden from other students.
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      i.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  StatusChip(i.status),
                ],
              ),
              const SizedBox(height: 12),
              Text('${i.category} • ${i.location}'),
              const SizedBox(height: 4),
              Text(
                'Reported by ${i.reporterName}'
                '${i.createdAt != null ? ' on ${fmt.format(i.createdAt!)}' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 32),
              Text(i.description),
              const Divider(height: 32),
              Text(
                'Status timeline',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              historyAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Could not load history: $e'),
                data: (list) {
                  if (list.isEmpty) {
                    return const Text('No updates yet.');
                  }
                  return Column(
                    children: list
                        .map(
                          (h) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.circle, size: 12),
                            title: Text(h.status),
                            subtitle: Text(
                              '${h.note.isEmpty ? '' : '${h.note}\n'}'
                              'by ${h.updatedBy}'
                              '${h.createdAt != null ? ' • ${fmt.format(h.createdAt!)}' : ''}',
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              if (me != null && me.isStaff) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Update status'),
                  onPressed: () =>
                      _showUpdateSheet(context, ref, i.id, i.status, me.name),
                ),
              ],
              if (isOwner && i.status == 'Submitted') ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete my report'),
                  onPressed: () => _confirmDelete(context, ref, i.id),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(incidentRepositoryProvider).delete(id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _showUpdateSheet(
    BuildContext context,
    WidgetRef ref,
    String id,
    String current,
    String staffName,
  ) {
    String selected = current;
    final note = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selected,
                decoration: const InputDecoration(labelText: 'New status'),
                items: AppConstants.statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setSheet(() => selected = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(incidentRepositoryProvider)
                          .updateStatus(
                            incidentId: id,
                            status: selected,
                            note: note.text.trim(),
                            staffName: staffName,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Update failed: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
