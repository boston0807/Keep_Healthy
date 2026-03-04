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
  
  FoodNutrient({required this.calories,required this.protein,required this.fat,required this.sodium,required this.carb,required this.sugar, this.point = 0, this.imageUrl = ""});

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
    if (point.isNaN) point = 0;
    
    return point;
  }

  static Future<FoodNutrient> createFoodNutrient(String docID) async{
    DatabaseService databaseService = DatabaseService();
    DocumentSnapshot documentSnapshot = await databaseService.getFoodNutrientFuture(docID);
    final data = documentSnapshot.data() as Map<String, dynamic>;
    return FoodNutrient(calories: data['calories'], protein: data['protein'], fat: data['fat'], sodium: data['sodium'], carb: data['carb'], sugar: data['sugar'], point: data['point'], imageUrl: data['image_url']);

  }
}