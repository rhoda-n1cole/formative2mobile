import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';
import '../models/status_update.dart';

class IncidentRepository {
  IncidentRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('incidents');

  Stream<List<Incident>> watchAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => Incident.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<Incident?> watchOne(String id) {
    return _col
        .doc(id)
        .snapshots()
        .map((d) => d.exists ? Incident.fromMap(d.id, d.data()!) : null);
  }

  Stream<List<StatusUpdate>> watchHistory(String id) {
    return _col
        .doc(id)
        .collection('statusHistory')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => StatusUpdate.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> create(Incident incident) async {
    await _col.add(incident.toMap());
  }

  Future<void> updateStatus({
    required String incidentId,
    required String status,
    required String note,
    required String staffName,
  }) async {
    final ref = _col.doc(incidentId);
    final batch = _db.batch();
    batch.update(ref, {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(ref.collection('statusHistory').doc(), {
      'status': status,
      'note': note,
      'updatedBy': staffName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}
