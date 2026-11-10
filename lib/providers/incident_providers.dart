import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incident.dart';
import '../models/status_update.dart';
import '../repositories/incident_repository.dart';
import '../repositories/storage_repository.dart';
import 'auth_providers.dart';

final incidentRepositoryProvider = Provider<IncidentRepository>(
  (ref) => IncidentRepository(ref.watch(firestoreProvider)),
);

final storageRepositoryProvider = Provider<StorageRepository>(
  (ref) => StorageRepository(cloudName: 'f2zthgqy', uploadPreset: 'tugdz25t'),
);

final incidentsProvider = StreamProvider<List<Incident>>(
  (ref) => ref.watch(incidentRepositoryProvider).watchAll(),
);

final incidentProvider = StreamProvider.family<Incident?, String>(
  (ref, id) => ref.watch(incidentRepositoryProvider).watchOne(id),
);

final historyProvider = StreamProvider.family<List<StatusUpdate>, String>(
  (ref, id) => ref.watch(incidentRepositoryProvider).watchHistory(id),
);

final supportCountProvider = StreamProvider.family<int, String>(
  (ref, id) => ref.watch(incidentRepositoryProvider).watchSupportCount(id),
);

final isSupporterProvider = StreamProvider.family<bool, String>((ref, id) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(false);
  return ref.watch(incidentRepositoryProvider).watchIsSupporter(id, uid);
});

// ---- Filters ----
const _unset = Object();

class IncidentFilter {
  final String query;
  final String? category;
  final String? status;
  const IncidentFilter({this.query = '', this.category, this.status});

  bool get isActive => query.isNotEmpty || category != null || status != null;

  IncidentFilter copyWith({
    String? query,
    Object? category = _unset,
    Object? status = _unset,
  }) => IncidentFilter(
    query: query ?? this.query,
    category: identical(category, _unset) ? this.category : category as String?,
    status: identical(status, _unset) ? this.status : status as String?,
  );
}

class FilterNotifier extends Notifier<IncidentFilter> {
  @override
  IncidentFilter build() => const IncidentFilter();
  void set(IncidentFilter f) => state = f;
}

final filterProvider = NotifierProvider<FilterNotifier, IncidentFilter>(
  FilterNotifier.new,
);

/// All incidents after applying search + filters.
final filteredIncidentsProvider = Provider<AsyncValue<List<Incident>>>((ref) {
  final f = ref.watch(filterProvider);
  return ref.watch(incidentsProvider).whenData((list) {
    final q = f.query.trim().toLowerCase();
    return list.where((i) {
      if (f.category != null && i.category != f.category) return false;
      if (f.status != null && i.status != f.status) return false;
      if (q.isNotEmpty &&
          !(i.title.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q) ||
              i.location.toLowerCase().contains(q))) {
        return false;
      }
      return true;
    }).toList();
  });
});
