import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keep_healthy/models/user.dart';
import '../models/food_nutriet.dart';

class DatabaseService {
  final CollectionReference user = FirebaseFirestore.instance.collection('user');
  final CollectionReference food = FirebaseFirestore.instance.collection('food_nutrient');

  Future<DocumentSnapshot> getUserFuture(String uID) {
    return user.doc(uID).get();
  }

  Future<void> updateProfileImageUrl(String imageUrl, String uID){
    return user.doc(uID).update({'image_url': imageUrl});
  }

  Future<void> uploadUserUsageCount(int usageCount, String uID){
    return user.doc(uID).update({'usage_count': usageCount});
  }

  Future<void> saveFoodNutrient(FoodNutriet foodNutriet, String uID, int usageCount, ){
    final String docID = uID + usageCount.toString();
    return food.doc(docID).set({
      'calories': foodNutriet.calories,
      'carb': foodNutriet.carb,
      'fat': foodNutriet.fat,
      'point': foodNutriet.point,
      'protein': foodNutriet.protein,
      'sodium': foodNutriet.sodium,
      'sugar': foodNutriet.sugar,
      'Date': DateTime.now()
    });
  }
}