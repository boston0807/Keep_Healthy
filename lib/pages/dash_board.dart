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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: 10,),
        Image.file(File(widget.imagePath), height: 300),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        Expanded(child: buildCard("Protein", foodNutriet!.protein.toStringAsFixed(1))),
                        Expanded(child: buildCard("Fat", foodNutriet!.fat.toStringAsFixed(1))),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(child: buildCard("Carb", foodNutriet!.carb.toStringAsFixed(1))),
                        Expanded(child: buildCard("Sugar", foodNutriet!.sugar.toStringAsFixed(1))),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(child: buildCard("Sodium", foodNutriet!.sodium.toStringAsFixed(0))),
                        Expanded(child: buildCard("Score", foodNutriet!.calculatePoint(widget.userWeight).toStringAsFixed(1))),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ]
    );
  }

  Widget buildCard(String title, String value) {
  return Container(
    margin: const EdgeInsets.all(10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
        const Color.fromARGB(255, 41, 155, 249),
        const Color.fromARGB(255, 114, 192, 255)
      ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
      ),
      border: Border.all(
        color: const Color.fromARGB(255, 1, 140, 253),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 5,
          offset: Offset(0, 3),
        )
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
}