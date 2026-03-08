import 'package:keep_healthy/pages/graph_page.dart';

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
  late final FoodNutrient? foodNutrient;
  late final List<FoodNutrient> foodList;
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    fetchFoodList();
  }

  @override
  void dispose(){
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (foodList.isEmpty) {
    return const Center(child: Text("No data"));
  }

  // return Column(
  //     children: [
  //       SizedBox(height: 70,),
  //       ElevatedButton(
  //       onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GraphPage(foodListRef: foodList, usageCount: widget.user.usageCount,))),
  //       child: Text("To graph Page")),
  //       Expanded(
  //           child: ListView.builder(
  //         itemCount: foodList.length,
  //         itemBuilder: (context, index) {
  //           final food = foodList[index];

  //           return Column(
  //             children: [
  //               Image.network(food!.imageUrl, width: 200),
  //               const SizedBox(height: 10),
  //               Text(food.point.toStringAsFixed(1)),
  //               const SizedBox(height: 30),
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //     ]
  //   );

  return Scaffold(
    appBar: AppBar(
      title: const Text("Dashboard"),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GraphPage(foodListRef: foodList, usageCount: widget.user.usageCount,))),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[300],
              elevation: 3,
              shadowColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("View Graph", style: TextStyle(color: Colors.black),),
          ),
        )
      ],
    ),
    body: GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: foodList.length,
      itemBuilder: (context, index) {
        final food = foodList[index];

        return GestureDetector(
          onTap: () {
            // Handle tap event for each food item
            Navigator.pushNamed(context, '/food-detail-page', arguments: {
              'foodName': 'Food ${index + 1}', // You can replace this with actual food name if available
              'imageUrl': food.imageUrl,
              'point': food.point,
            });
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            child: Padding(
              padding: const EdgeInsets.all(10.0),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:Image.network(food.imageUrl, width: 150, height: 150, fit: BoxFit.cover,),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    food.point.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Future<void> fetchFoodList() async {
  try {
    final String uID = auth.FirebaseAuth.instance.currentUser!.uid;

    foodList = await FoodNutrient.createFoodNutrientList(
      uID,
      widget.user.usageCount,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  } catch (e) {
    print("fetch list error $e \n uID: ${auth.FirebaseAuth.instance.currentUser!.uid}");
    }
  }
}