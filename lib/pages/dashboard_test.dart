import 'package:keep_healthy/pages/graph_page.dart';
import '../models/food_nutrient.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class DashboardTest extends StatefulWidget {
  final User user;
  const DashboardTest({super.key, required this.user});

  @override
  State<DashboardTest> createState() => _DashboardTestState();
}

class _DashboardTestState extends State<DashboardTest> {
  late List<FoodNutrient> foodList;
  bool isLoading = true;

  static const _bg = Color(0xFF0F1117);
  static const _card = Color(0xFF1A1F35);
  static const _purple = Color(0xFF6C63FF);
  static const _teal = Color(0xFF00D4AA);

  static const _months = [
    "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  @override
  void initState() {
    super.initState();
    fetchFoodList();
  }

  Map<String, List<FoodNutrient>> get _grouped {
    final Map<String, List<FoodNutrient>> map = {};
    for (final f in foodList) {
      final d = f.date!;
      final key = "${_months[d.month]} ${d.year.toString()}";
      map.putIfAbsent(key, () => []);
      map[key]!.add(f);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _purple)),
      );
    }

    if (foodList.isEmpty) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.no_food_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text("No data yet",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    final grouped = _grouped;
    final keys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 42, 58),
        elevation: 0,
        title: const Text("Dashboard",
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => GraphPage(
                        foodListRef: foodList,
                        usageCount: widget.user.usageCount))),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_purple, _teal]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text("Graph",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        itemCount: keys.length,
        itemBuilder: (context, sectionIndex) {
          final monthKey = keys[sectionIndex];
          final items = grouped[monthKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_purple, _teal],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      monthKey,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Text("${items.length} items",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 12)),
                  ],
                ),
              ),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final food = items[index];
                  final score = food.point;
                  final color = score >= 80
                      ? _teal
                      : score >= 50
                          ? Colors.orange
                          : const Color(0xFFFF7B9C);

                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, '/food-detail-page',
                        arguments: {
                          'foodName': 'Food ${index + 1}',
                          'imageUrl': food.imageUrl,
                          'point': food.point,
                        }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.07)),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: Image.network(
                                food.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.white.withOpacity(0.05),
                                  child: Icon(Icons.broken_image_rounded,
                                      color:
                                          Colors.white.withOpacity(0.2)),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Health Score",
                                        style: TextStyle(
                                            color: Colors.white
                                                .withOpacity(0.45),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500)),
                                    Text(score.toStringAsFixed(1),
                                        style: TextStyle(
                                            color: color,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: score / 100,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.08),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> fetchFoodList() async {
    try {
      final String uID = auth.FirebaseAuth.instance.currentUser!.uid;
      foodList = await FoodNutrient.createFoodNutrientList(
          uID, widget.user.usageCount);
      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (e) {
      print("fetch list error $e");
    }
  }
}