import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.createdAt,
  });

  bool get isStaff => role == 'staff';

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'name': name,
    'role': role,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
