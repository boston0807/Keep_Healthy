import 'package:flutter/material.dart';
import 'package:keep_healthy/models/food_nutrient.dart';
import 'package:keep_healthy/models/user.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/log_meal_service.dart';
import 'dart:async';
import '../services/database_service.dart';
import '../services/cloudinary_service.dart';
import '../providers/theme_provider.dart';

class DashBoard extends StatefulWidget {
  final User user;
  final String uID;
  final String imagePath;
  final double userWeight;

  const DashBoard({super.key, required this.imagePath, required this.userWeight, required this.user, required this.uID});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  FoodNutrient? foodNutriet;
  bool isLoading = true;

  static const _accentGreen = Color(0xFF3ECFA3);
  static const _accentRed = Color(0xFFFF5C6A);
  static const _accentYellow = Color(0xFFFFD166);

  @override
  void initState() {
    super.initState();
    processImage();
  }

  Future<void> processImage() async {
    FoodNutrient result = await LogMealService.analyzeFood(widget.imagePath);
    result.date = DateTime.now();
    setState(() {
      foodNutriet = result;
      isLoading = false;
    });
    result.calculatePoint(widget.userWeight);
    try {
      DatabaseService databaseService = DatabaseService();
      CloudinaryService cloudinaryService = CloudinaryService();
      await databaseService.uploadUserUsageCount(++widget.user.usageCount, widget.uID);
      result.imageUrl = await cloudinaryService.uploadFoodNutrient(widget.imagePath, widget.uID+widget.user.usageCount.toString()); 
      await databaseService.saveFoodNutrient(result, widget.uID, widget.user.usageCount);
      print("Upload user usageCount and save food Nutrient Complete");
    } catch (e){
      print("Upload user usageCount and save food Nutrient error $e");
    }
  }

  Color _pointColor(double point) {
    if (point >= 70) return _accentGreen;
    if (point >= 40) return _accentYellow;
    return _accentRed;
  }

  String _pointLabel(double point) {
    if (point >= 70) return "Excellent";
    if (point >= 40) return "Moderate";
    return "Poor";
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.accent),
            const SizedBox(height: 16),
            Text("Analyzing your meal...",
                style: TextStyle(color: theme.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    final food = foodNutriet!;
    final pointColor = _pointColor(food.point);
    final pointLabel = _pointLabel(food.point);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: theme.bg,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCC0F1117),
                      ],
                      stops: [0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Body
        SliverToBoxAdapter(
          child: Container(
            color: theme.bg,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,    
                  children: [
                    Text(
                      food.menuName,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(width: 20,),
                    if (food.date != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 20, color: theme.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            _formatDate(food.date ?? DateTime.now()),
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                _ScoreCard(
                  point: food.point,
                  pointColor: pointColor,
                  pointLabel: pointLabel,
                ),

                const SizedBox(height: 24),
                Text(
                  "NUTRITION FACTS",
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                _CalorieRow(calories: food.calories),
                const SizedBox(height: 12),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    _NutrientTile(
                      label: "Protein",
                      value: food.protein,
                      unit: "g",
                      icon: Icons.fitness_center_rounded,
                      color: _accentGreen,
                    ),
                    _NutrientTile(
                      label: "Carbohydrate",
                      value: food.carb,
                      unit: "g",
                      icon: Icons.grain_rounded,
                      color: _accentYellow,
                    ),
                    _NutrientTile(
                      label: "Fat",
                      value: food.fat,
                      unit: "g",
                      icon: Icons.opacity_rounded,
                      color: _accentRed,
                    ),
                    _NutrientTile(
                      label: "Sugar",
                      value: food.sugar,
                      unit: "g",
                      icon: Icons.water_drop_rounded,
                      color: const Color(0xFFE879F9),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _SodiumRow(sodium: food.sodium),

                const SizedBox(height: 24),

                AdviceSection(advice: food.getAdvice(widget.userWeight)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}

class _ScoreCard extends StatelessWidget {
  final double point;
  final Color pointColor;
  final String pointLabel;

  const _ScoreCard({
    required this.point,
    required this.pointColor,
    required this.pointLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pointColor.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: point / 100,
                  strokeWidth: 6,
                  backgroundColor: pointColor.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(pointColor),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  point.toStringAsFixed(0),
                  style: TextStyle(
                    color: pointColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health Score",
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pointLabel,
                  style: TextStyle(
                    color: pointColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: point / 100,
                    minHeight: 5,
                    backgroundColor: pointColor.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(pointColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieRow extends StatelessWidget {
  final double calories;

  const _CalorieRow({required this.calories});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: theme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.local_fire_department_rounded,
                color: theme.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            "Calories",
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: calories.toStringAsFixed(0),
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: " kcal",
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientTile extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;

  const _NutrientTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SodiumRow extends StatelessWidget {
  final double sodium;

  static const _sodiumColor = Color(0xFFFFB347);
  static const double _maxSodium = 2000;

  const _SodiumRow({required this.sodium});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    final ratio = (sodium / _maxSodium).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _sodiumColor.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_rounded,
                  color: _sodiumColor, size: 16),
              const SizedBox(width: 6),
              Text(
                "Sodium",
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: sodium.toStringAsFixed(0),
                      style: const TextStyle(
                        color: _sodiumColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: " / 2000 mg",
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: _sodiumColor.withOpacity(0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(_sodiumColor),
            ),
          ),
        ],
      ),
    );
  }
}

class AdviceSection extends StatelessWidget {
  final List<String> advice;

  const AdviceSection({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    if (advice.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded,
                  color: theme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                "ADVICE",
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...advice.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• ",
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}