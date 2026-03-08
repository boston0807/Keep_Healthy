import "package:flutter/material.dart";

class FoodDetailPage extends StatelessWidget {
  final String foodName;
  final String imageUrl;
  final double point;

  const FoodDetailPage({
    super.key,
    required this.foodName,
    required this.imageUrl,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(foodName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imageUrl, width: double.infinity, height: 300, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(
              "Nutrient Point: ${point.toStringAsFixed(1)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}