import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/incident.dart';
import 'status_chip.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident, required this.onTap});
  final Incident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = incident.createdAt == null
        ? ''
        : DateFormat('d MMM, HH:mm').format(incident.createdAt!);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(
          incident.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${incident.category} • ${incident.location}\n$date'),
        ),
        isThreeLine: true,
        trailing: StatusChip(incident.status),
      ),
    );
  }
}
