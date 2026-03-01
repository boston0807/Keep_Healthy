import 'package:flutter/material.dart';
import 'package:keep_healthy/models/food_nutriet.dart';
import 'package:keep_healthy/models/user.dart';
import 'dart:io';
import '../services/log_meal_service.dart';
import 'dart:async';

class DashBoard extends StatefulWidget {
  final String imagePath;
  final double userWeight;

  const DashBoard({super.key, required this.imagePath, required this.userWeight});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  FoodNutriet? foodNutriet;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    processImage();
  }

  Future<void> processImage() async {
    FoodNutriet result = await LogMealService.analyzeFood(widget.imagePath);

    setState(() {
      foodNutriet = result;
      isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Image.file(File(widget.imagePath), height: 300),

        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              Text("Calories: ${foodNutriet!.calories}"),
              Text("Protein: ${foodNutriet!.protein}"),
              Text("Fat: ${foodNutriet!.fat}"),
              Text("Carb: ${foodNutriet!.carb}"),
              Text("Sugar: ${foodNutriet!.sugar}"),
              Text("Sodium: ${foodNutriet!.sodium}"),
              Text("Healthy Score: ${foodNutriet!.calculatePoint(widget.userWeight)}")
            ],
          ),
        )
      ],
    );
  }
}