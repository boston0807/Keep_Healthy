import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class FoodNutrient {
  final double calories;
  final double protein;
  final double fat;
  final double sodium;
  final double carb;
  final List<String> advice = [];
  final double sugar;
  double point ;
  String imageUrl;
  final String menuName;
  DateTime? date ;
  
  FoodNutrient({required this.calories,required this.protein,required this.fat,required this.sodium,required this.carb,required this.sugar, this.point = 0, this.imageUrl = "", this.date, required this.menuName});

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
    return FoodNutrient(calories: data['calories'], protein: data['protein'], fat: data['fat'], sodium: data['sodium'], carb: data['carb'], sugar: data['sugar'], point: data['point'], imageUrl: data['image_url'], date: (data['Date'] as Timestamp).toDate(), menuName: data['name']);
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
        date: (data['Date'] as Timestamp).toDate(),
        menuName: data['name'],
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
  
  List<String> getAdvice(double weight) {
  if (weight <= 0) return advice;
  double maxProtein = weight * 1.0;
  double maxCalories = weight * 27;
  double maxFat = (maxCalories * 0.3) / 9;
  double maxCarb = (maxCalories * 0.5) / 4;
  double maxSugar = 25;
  double maxSodium = 2000;

  double proteinRatio = protein / maxProtein;
  double calorieRatio = calories / maxCalories;
  double fatRatio = fat / maxFat;
  double carbRatio = carb / maxCarb;
  double sugarRatio = sugar / maxSugar;
  double sodiumRatio = sodium / maxSodium;

  if (calorieRatio > 0.4) {
    advice.add("Calories ค่อนข้างสูงสำหรับมื้อนี้");
  }

  if (fatRatio > 0.4) {
    advice.add("ไขมันค่อนข้างสูง");
  }

  if (sodiumRatio > 0.4) {
    advice.add("โซเดียมสูง อาจเสี่ยงความดัน");
  } else{
    advice.add("โซเดียมต่ำกำลังดี");
  }

  if (sugarRatio > 0.4) {
    advice.add("น้ำตาลค่อนข้างสูง");
  } else{
    advice.add("น้ำตาลต่ำพอเหมาะสม");
  }

  if (proteinRatio < 0.2) {
    advice.add("โปรตีนน้อย ควรเพิ่มแหล่งโปรตีน");
  } else{
    advice.add("");
  }

  if (advice.isEmpty) {
    advice.add("มื้อนี้สมดุลดี");
  }

  if (carbRatio > 0.35){
    advice.add("ปริมาณคาร์โบไฮเดรตในมื้อนี้ค่อนข้างสูง");
  } else {
    advice.add("ปริมาณคาร์โบไฮเดรตกำลังเหมาะสม");
  } 

  return advice;
  }
}