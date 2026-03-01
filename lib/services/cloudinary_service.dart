import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = "keephealthy";
  final String uploadPreset = "user_upload";

  Future<String?> upload(String imagePath, String userID) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url);

    request.fields['upload_preset'] = uploadPreset;
    request.fields['public_id'] = userID;

    request.files.add(
      await http.MultipartFile.fromPath('file', imagePath),
    );

    final response = await request.send();
    final respondBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final data = jsonDecode(respondBody);
      print("Upload success");
      return data['secure_url'];
    } else {
      print("Upload failed: ${response.statusCode}");
      return null;
    }
  }

  String getProfileImageUrl(String userId) {
    return "https://res.cloudinary.com/keephealthy/image/upload/profile_images/$userId";
  }
}