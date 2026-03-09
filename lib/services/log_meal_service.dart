import 'dart:convert';
import '../models/food_nutrient.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

class LogMealService {
  static final String apiKey = "6ff80e94d4c984eab08cbc03f2f1fbfeb3297336";
  static final String baseUrl = 'https://api.logmeal.com/v2';

  const LogMealService._();

  static Future<RegonizeResult> getImageID(String imagePath) async{
    final url = Uri.parse("$baseUrl/image/segmentation/complete");

    final request = http.MultipartRequest('post', url);
    request.headers['Authorization'] = "Bearer $apiKey";

    request.files.add(await http.MultipartFile.fromPath("image", imagePath),); 
    final streamRespond = await request.send();
    final respond = await http.Response.fromStream(streamRespond);
    if (respond.statusCode == 200){
      final data = jsonDecode(respond.body);
      return RegonizeResult(imageID: (data['imageId']).toString(), menuName: data['segmentation_results'][0]['recognition_results'][0]['name']);
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

    static Future<FoodNutrient> analyzeFood(String imagePath) async{
      RegonizeResult result = await getImageID(imagePath);
      return await getFoodNutrient(result.imageID, result.menuName);
    }

    static Future<FoodNutrient> getFoodNutrient(String imageID, String menuName) async{
      final url = Uri.parse("$baseUrl/nutrition/recipe/nutritionalInfo");
      final respond = await http.post(url,headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'}, body: jsonEncode({'imageId' : imageID}));
      if (respond.statusCode == 200){
        final data = jsonDecode(respond.body);
        return FoodNutrient(calories: data['nutritional_info']['calories'],protein:  data['nutritional_info']['totalNutrients']['PROCNT']["quantity"],fat: data['nutritional_info']['totalNutrients']['FAT']["quantity"],carb: data['nutritional_info']['totalNutrients']["CHOCDF"]["quantity"],sugar: data['nutritional_info']['totalNutrients']["SUGAR"]["quantity"],sodium: data['nutritional_info']['totalNutrients']["NA"]["quantity"], menuName: menuName);
      }else{ 
        throw respond.statusCode;
      }
    }
}

class RegonizeResult {
  final String menuName;
  final String imageID;

  const RegonizeResult({required this.imageID, required this.menuName});
}