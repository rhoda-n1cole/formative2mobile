import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageRepository {
  StorageRepository(this._storage);
  final FirebaseStorage _storage;

  /// Uploads a picked image and returns its download URL.
  Future<String> uploadIncidentImage(String uid, XFile file) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref('incident_images/$uid/$name');
    await ref.putFile(
      File(file.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}
