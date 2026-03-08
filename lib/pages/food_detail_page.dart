import "package:flutter/material.dart";
import '../models/food_nutrient.dart';

class FoodDetailPage extends StatelessWidget {
  final String foodName;
  final FoodNutrient food;

  const FoodDetailPage({
    super.key,
    required this.foodName,
    required this.food,
  });

  static const _bg = Color(0xFF0F1117);
  static const _card = Color(0xFF1A1F35);
  static const _accentGreen = Color(0xFF3ECFA3);
  static const _accentRed = Color(0xFFFF5C6A);
  static const _accentYellow = Color(0xFFFFD166);
  static const _textPrimary = Color(0xFFEEF0F8);
  static const _textSecondary = Color(0xFF7B82A3);

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
    final pointColor = _pointColor(food.point);
    final pointLabel = _pointLabel(food.point);

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          // Back Button
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: _bg,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: _card.withOpacity(0.85),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _textPrimary, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Food image
                  food.imageUrl.isNotEmpty
                      ? Image.network(
                          food.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _placeholderImage(),
                        )
                      : _placeholderImage(),

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

                  // Food index and date
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodName,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        if (food.date != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 13, color: _textSecondary),
                              const SizedBox(width: 5),
                              Text(
                                _formatDate(food.date!),
                                style: const TextStyle(
                                  color: _textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Score Card
                  _ScoreCard(
                    point: food.point,
                    pointColor: pointColor,
                    pointLabel: pointLabel,
                  ),

                  const SizedBox(height: 24),

                  // Section title
                  const Text(
                    "NUTRITION FACTS",
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Calorie highlight row
                  _CalorieRow(calories: food.calories),

                  const SizedBox(height: 12),

                  // Nutrient grid View
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

                  // Sodium Row
                  _SodiumRow(sodium: food.sodium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: _card,
      child: const Center(
        child: Icon(Icons.restaurant_rounded, size: 72, color: _textSecondary),
      ),
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

// Health Score Card

class _ScoreCard extends StatelessWidget {
  final double point;
  final Color pointColor;
  final String pointLabel;

  static const _card = Color(0xFF1A1F35);
  static const _textPrimary = Color(0xFFEEF0F8);
  static const _textSecondary = Color(0xFF7B82A3);

  const _ScoreCard({
    required this.point,
    required this.pointColor,
    required this.pointLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pointColor.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        children: [
          // Circular score indicator
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

          // Label section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health Score",
                  style: TextStyle(
                    color: _textSecondary,
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

// Calorie highlight row

class _CalorieRow extends StatelessWidget {
  final double calories;

  static const _card = Color(0xFF1A1F35);
  static const _accent = Color(0xFF4F8EF7);
  static const _textPrimary = Color(0xFFEEF0F8);
  static const _textSecondary = Color(0xFF7B82A3);

  const _CalorieRow({required this.calories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: _accent, size: 22),
          ),
          const SizedBox(width: 14),
          const Text(
            "Calories",
            style: TextStyle(
              color: _textPrimary,
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
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(
                  text: " kcal",
                  style: TextStyle(
                    color: _textSecondary,
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

// Nutrient tile card

class _NutrientTile extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;

  static const _card = Color(0xFF1A1F35);
  static const _textPrimary = Color(0xFFEEF0F8);
  static const _textSecondary = Color(0xFF7B82A3);

  const _NutrientTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
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
                style: const TextStyle(
                  color: _textSecondary,
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
                  style: const TextStyle(
                    color: _textSecondary,
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

// Sodium row 

class _SodiumRow extends StatelessWidget {
  final double sodium;

  static const _card = Color(0xFF1A1F35);
  static const _textPrimary = Color(0xFFEEF0F8);
  static const _textSecondary = Color(0xFF7B82A3);
  static const _sodiumColor = Color(0xFFFFB347);
  static const double _maxSodium = 2000;

  const _SodiumRow({required this.sodium});

  @override
  Widget build(BuildContext context) {
    final ratio = (sodium / _maxSodium).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _sodiumColor.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_rounded, color: _sodiumColor, size: 16),
              const SizedBox(width: 6),
              const Text(
                "Sodium",
                style: TextStyle(
                  color: _textSecondary,
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
                    const TextSpan(
                      text: " / 2000 mg",
                      style: TextStyle(
                        color: _textSecondary,
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
              valueColor: AlwaysStoppedAnimation<Color>(_sodiumColor),
            ),
          ),
        ],
      ),
    );
  }
}