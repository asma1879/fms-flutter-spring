import 'dart:convert';
import 'dart:io';
import 'package:freelance_app/models/freelancer_profile.dart';
import 'package:http/http.dart' as http;
//import 'freelancer_profile.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class FreelancerProfileService {
  static const String baseUrl = 'http://localhost:8080/api/auth/freelancer/profile';

  Future<FreelancerProfile> getProfile(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/$userId'));
    if (res.statusCode == 200) {
      return FreelancerProfile.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<FreelancerProfile> updateProfile(FreelancerProfile profile) async {
    final res = await http.post(
      Uri.parse('$baseUrl/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profile.toJson()),
    );
    if (res.statusCode == 200) {
      return FreelancerProfile.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<String> uploadImage(File file) async {
    final uri = Uri.parse('$baseUrl/upload-image');
    final request = http.MultipartRequest('POST', uri);

    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType.parse(mimeType),
    ));

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode == 200) {
      // Backend returns image path like "/uploads/profile_images/uuid_filename.jpg"
      return res.body;
    } else {
      throw Exception('Image upload failed');
    }
  }
}
