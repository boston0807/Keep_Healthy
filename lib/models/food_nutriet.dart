class FoodNutriet {
  final double calories;
  final double protein;
  final double fat;
  final double sodium;
  final double carb;
  final double sugar;
  
  const FoodNutriet({required this.calories,required this.protein,required this.fat,required this.sodium,required this.carb,required this.sugar});

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

    double good = proteinRatio * 2;

    double bad =
        calorieRatio * 1 +
        fatRatio * 0.8 +
        carbRatio * 0.5 +
        sugarRatio * 1.0 +
        sodiumRatio * 1.0;

    double score = good / (good + bad);
    if (score.isNaN) score = 0;

    return score * 100;
  }
}