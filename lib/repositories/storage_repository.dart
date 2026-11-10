import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Uploads report photos to Cloudinary and returns the image URL.
class StorageRepository {
  StorageRepository({required this.cloudName, required this.uploadPreset});

  final String cloudName;
  final String uploadPreset;

  Future<String> uploadIncidentImage(String uid, XFile file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'incident_images/$uid'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw Exception('Photo upload failed (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['secure_url'] as String;
  }
}
