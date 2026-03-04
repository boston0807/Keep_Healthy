import '../models/food_nutrient.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class DashboardTest extends StatefulWidget {
  final User user ;
  const DashboardTest({super.key, required this.user});

  @override
  State<DashboardTest> createState() => _DashboardTestState();
}

class _DashboardTestState extends State<DashboardTest> {
  late final FoodNutrient foodNutrient;
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    fetchOneFoodNutrient();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    Center(
      child: CircularProgressIndicator(),
    ) 
    :
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(foodNutrient.imageUrl, width: 250,),
          SizedBox(height: 80,),
          Text(foodNutrient.point.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Future<void> fetchOneFoodNutrient() async{
    try{
      final String uID = auth.FirebaseAuth.instance.currentUser!.uid;
      final String docID = uID + widget.user.usageCount.toString();
      print("image url $docID");
      foodNutrient = await FoodNutrient.createFoodNutrient(docID);
      print("fetch one food complete");
          setState(() {
      isLoading = false;
      });
    } catch(e){
      print("fetch one food error $e");
    }
  }
}