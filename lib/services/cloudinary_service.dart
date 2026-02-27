import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = "keephealthy";
  final String uploadPreset = "user_upload";

  Future<void> upload(String imagePath, String userID) async {
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

    if (response.statusCode == 200) {
      print("Upload success");
    } else {
      print("Upload failed: ${response.statusCode}");
    }
  }
}