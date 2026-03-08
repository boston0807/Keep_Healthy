import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = "keephealthy";


  Future<String?> uploadProfilePicture(String imagePath) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url);

    request.fields['upload_preset'] = "user_upload";

    
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

    Future<String> uploadFoodNutrient(String imagePath, String docID) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url);

    request.fields['upload_preset'] = "food_picture_upload";
    request.fields['public_id'] = docID;

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
      throw "Upload Failed";
    }
  }

  Future<void> getSignature(String uID) async{

  }

}