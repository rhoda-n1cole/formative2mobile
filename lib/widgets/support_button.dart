import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../providers/incident_providers.dart';

class SupportButton extends ConsumerWidget {
  const SupportButton({super.key, required this.incidentId});
  final String incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(supportCountProvider(incidentId)).value ?? 0;
    final mine = ref.watch(isSupporterProvider(incidentId)).value ?? false;
    final uid = ref.watch(authStateProvider).value?.uid;

    return OutlinedButton.icon(
      icon: Icon(mine ? Icons.thumb_up : Icons.thumb_up_outlined),
      label: Text('Me too ($count)'),
      onPressed: uid == null
          ? null
          : () => ref
                .read(incidentRepositoryProvider)
                .setSupport(incidentId, uid, !mine),
    );
  }
}
