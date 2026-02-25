import 'dart:convert';
import '../models/food_nutriet.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

class LogMealService {
  static final String apiKey = "cd8370fb5987ae506757aa97938844d192b92ca5";
  static final String baseUrl = 'https://api.logmeal.com/v2';

  const LogMealService._();

  static Future<String> getImageID(String imagePath) async{
    final url = Uri.parse("$baseUrl/image/segmentation/complete");

    final request = http.MultipartRequest('post', url);
    request.headers['Authorization'] = "Bearer $apiKey";

    request.files.add(await http.MultipartFile.fromPath("image", imagePath),); 
    final streamRespond = await request.send();
    final respond = await http.Response.fromStream(streamRespond);
    if (respond.statusCode == 200){
      final data = jsonDecode(respond.body);
      return data['imageId'].toString();
    } else if (respond.statusCode == 401){
      throw ("Invalid API key");
    } else if (respond.statusCode == 429){
      throw ("Rate limit");
    } else{
        throw (respond.statusCode);
    }
  }

    static Future<String> encodeImage64(String imagePath) async {
      File imageFile = File(imagePath);
      List<int> imageByte = await imageFile.readAsBytes();
    return base64Encode(imageByte);
  }

    static Future<FoodNutriet> analyzeFood(String imagePath) async{
      String imageID = await getImageID(imagePath);
      return await getFoodNutrient(imageID);
    }

    static Future<FoodNutriet> getFoodNutrient(String imageID) async{
      final url = Uri.parse("$baseUrl/nutrition/recipe/nutritionalInfo");
      final respond = await http.post(url,headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'}, body: jsonEncode({'imageId' : imageID}));
      if (respond.statusCode == 200){
        final data = jsonDecode(respond.body);
        return FoodNutriet(data['nutritional_info']['calories'], data['nutritional_info']['totalNutrients']['PROCNT']["quantity"]);
      }else{ 
        throw respond.statusCode;
      }
    }

}