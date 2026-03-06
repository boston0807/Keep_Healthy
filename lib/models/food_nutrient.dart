import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class FoodNutrient {
  final double calories;
  final double protein;
  final double fat;
  final double sodium;
  final double carb;
  final double sugar;
  double point ;
  String imageUrl;
  DateTime? date ;
  
  FoodNutrient({required this.calories,required this.protein,required this.fat,required this.sodium,required this.carb,required this.sugar, this.point = 0, this.imageUrl = "", this.date});

  double calculatePoint(double weight) {
    if (weight <= 0) return 0;

    double maxProtein = weight * 1.0;
    double maxCalories = weight * 27;
    double maxFat = (maxCalories * 0.3) / 9;
    double maxCarb = (maxCalories * 0.5) / 4;
    double maxSugar = 25; 
    double maxSodium = 2000;

    double proteinRatio = (protein / maxProtein).clamp(0, 1);
    double calorieRatio = (calories / maxCalories).clamp(0, 1);
    double fatRatio = (fat / maxFat).clamp(0, 1);
    double carbRatio = (carb / maxCarb).clamp(0, 1);
    double sugarRatio = (sugar / maxSugar).clamp(0, 1); 
    double sodiumRatio = (sodium / maxSodium).clamp(0, 1);
    
    double good = proteinRatio * 2 + (1 - fatRatio) * 0.5 + (1 - sugarRatio) * 1.0;

    double bad = calorieRatio * 0.7 + fatRatio * 0.5 + carbRatio * 0.3 + sugarRatio * 0.8 + sodiumRatio * 0.7;

    point = (good / (good + bad) * 100);
    if (point.isNaN || point < 0) point = 0;
    if (point > 100) point = 100;
    return point;
  }

  static Future<FoodNutrient> createFoodNutrient(String docID) async{
    DatabaseService databaseService = DatabaseService();
    DocumentSnapshot documentSnapshot = await databaseService.getFoodNutrientFuture(docID);
    final data = documentSnapshot.data() as Map<String, dynamic>;
    return FoodNutrient(calories: data['calories'], protein: data['protein'], fat: data['fat'], sodium: data['sodium'], carb: data['carb'], sugar: data['sugar'], point: data['point'], imageUrl: data['image_url'], date: (data['Date'] as Timestamp).toDate());
  }

  static Future<List<FoodNutrient>> createFoodNutrientList(String uID, int usage) async {
    if (usage == 0){ 
      print("Fetch List of FoodNutrinet failed");
      throw Exception("This is your first time try use our Keep Healthy");
    }
    DatabaseService databaseService = DatabaseService();
    List<FoodNutrient> list = [];
    int i = usage;
    print("Start fetch food List for uID: $uID \n usageCount: $usage");
    while (i > 0) {
      DocumentSnapshot documentSnapshot = await databaseService.getFoodNutrientFuture(uID + i.toString());
      if (documentSnapshot.data() == null) {
        i--;
        continue;
      } 
      var data = documentSnapshot.data() as Map<String, dynamic>;
      FoodNutrient food = FoodNutrient(
        calories: data['calories'],
        protein: data['protein'],
        fat: data['fat'],
        sodium: data['sodium'],
        carb: data['carb'],
        sugar: data['sugar'],
        point: data['point'],
        imageUrl: data['image_url'],
        date: (data['Date'] as Timestamp).toDate()
      );
      list.add(food);
      i--;
    }
    print("Fetch food list $uID complete");
    return list;
  }

  static double maxPoint(List<FoodNutrient> foodList){
    if (foodList.isEmpty) throw Exception("foodList is Empty");
    double maxPoint = -99999999;
    for (FoodNutrient food in foodList){
      if (food.point > maxPoint) maxPoint = food.point;
    }
    return maxPoint;
  }

  static double minPoint(List<FoodNutrient> foodList){
    if (foodList.isEmpty) throw Exception("foodList is Empty");
    double minPoint = 99999999;
    for (FoodNutrient food in foodList){
      if (food.point < minPoint) minPoint = food.point;
    }
    return minPoint;
  }
}