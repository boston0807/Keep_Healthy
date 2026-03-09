import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_nutrient.dart';

class DatabaseService {
  final CollectionReference user = FirebaseFirestore.instance.collection('user');
  final CollectionReference food = FirebaseFirestore.instance.collection('food_nutrient');

  Future<DocumentSnapshot> getUserFuture(String uID) async{
    return await user.doc(uID).get();
  }

  Future<DocumentSnapshot> getFoodNutrientFuture(String docID) async{
    return await food.doc(docID).get();
  }

  Future<void> updateProfileImageUrl(String imageUrl, String uID){
    return user.doc(uID).update({'image_url': imageUrl});
  }

  Future<void> uploadUserUsageCount(int usageCount, String uID){
    return user.doc(uID).update({'usage_count': usageCount});
  }

  Future<void> saveFoodNutrient(FoodNutrient foodNutriet, String uID, int usageCount, ){
    final String docID = uID + usageCount.toString();
    return food.doc(docID).set({
      'calories': foodNutriet.calories,
      'carb': foodNutriet.carb,
      'fat': foodNutriet.fat,
      'point': foodNutriet.point,
      'protein': foodNutriet.protein,
      'sodium': foodNutriet.sodium,
      'sugar': foodNutriet.sugar,
      'Date': DateTime.now(),
      'image_url': foodNutriet.imageUrl,
      'name': foodNutriet.menuName,
    });
  }

  Future<void> updateUserWeight(String uID, double weight){
    return user.doc(uID).update({'weight': weight});
  }

  Future<void> updateUserUsername(String uID, String username){
    return user.doc(uID).update({'username': username});
  }

  Future<void> updateUserFirstName(String uID, String firstName){
    return user.doc(uID).update({"first_name": firstName});
  }

  Future<void> updateUserSurName(String uID, String surName){
    return user.doc(uID).update({"sur_name": surName});
  }

  Future<void> updateUserEmail(String uID, String email){
    return user.doc(uID).update({"email": email});
  }
}