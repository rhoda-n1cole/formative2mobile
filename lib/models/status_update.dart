import 'package:cloud_firestore/cloud_firestore.dart';

class StatusUpdate {
  final String id;
  final String status;
  final String note;
  final String updatedBy;
  final DateTime? createdAt;

  const StatusUpdate({
    required this.id,
    required this.status,
    required this.note,
    required this.updatedBy,
    this.createdAt,
  });

  factory StatusUpdate.fromMap(String id, Map<String, dynamic> map) {
    return StatusUpdate(
      id: id,
      status: map['status'] ?? '',
      note: map['note'] ?? '',
      updatedBy: map['updatedBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'status': status,
    'note': note,
    'updatedBy': updatedBy,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
