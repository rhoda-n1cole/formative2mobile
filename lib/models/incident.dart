import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String location;
  final String? imageUrl;
  final String reporterId;
  final String reporterName;
  final bool isAnonymous;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.location,
    required this.reporterId,
    required this.reporterName,
    this.imageUrl,
    this.isAnonymous = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Incident.fromMap(String id, Map<String, dynamic> map) {
    return Incident(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      status: map['status'] ?? 'Submitted',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'],
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      isAnonymous: map['isAnonymous'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'status': status,
        'location': location,
        'imageUrl': imageUrl,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'isAnonymous': isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
