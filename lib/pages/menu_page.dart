import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:fl_chart/fl_chart.dart';
import '../models/user.dart';
import '../models/food_nutrient.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class MenuPage extends StatefulWidget {
  final User? user;
  const MenuPage({super.key, required this.user});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<FoodNutrient> foodList = [];
  bool isLoading = true;
  late final FoodNutrient? last ;

  static const _purple = Color(0xFF6C63FF);
  static const _teal = Color(0xFF00D4AA);
  static const _pink = Color(0xFFFF7B9C);

  @override
  void initState() {
    super.initState();
    if (widget.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/login-page",
          (_) => false,
        );
      });
      return;
    }
    fetchFoodList();
  }

  Future<void> fetchFoodList() async {
    try {
      final uID = auth.FirebaseAuth.instance.currentUser!.uid;
      final list = await FoodNutrient.createFoodNutrientList(
        uID,
        widget.user!.usageCount,
      );
      if (list.isNotEmpty) {
        list.sort((a, b) => a.date!.compareTo(b.date!));
        list.last.getAdvice(widget.user!.weight);
      }
      if (!mounted) return;
      setState(() {
        foodList = list;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  FoodNutrient? get lastMeal {
    if (foodList.isEmpty) return null;

    final sorted = List<FoodNutrient>.from(foodList)
      ..sort((a, b) => a.date!.compareTo(b.date!));

    return sorted.last;
  }

  List<FlSpot> get _spots {
    DateTime now = DateTime.now();
    DateTime start = now.subtract(const Duration(days: 6));
    Map<String, List<double>> groups = {};
    int i = 0;
    while (i < foodList.length) {
      FoodNutrient f = foodList[i];
      DateTime d = f.date!;
      if (d.isAfter(start.subtract(const Duration(days: 1))) &&
          d.isBefore(now.add(const Duration(days: 1)))) {
        String key = "${d.day}/${d.month}";
        if (!groups.containsKey(key)) {
          groups[key] = [];
        }
        groups[key]!.add(f.point);
      }
      i++;
    }
    List<String> keys = groups.keys.toList();
    keys.sort();
    List<FlSpot> spots = [];
    int j = 0;
    while (j < keys.length) {
      String k = keys[j];
      List<double> values = groups[k]!;
      double sum = 0;
      int p = 0;
      while (p < values.length) {
        sum = sum + values[p];
        p++;
      }
      double avg = sum / values.length;
      spots.add(FlSpot(j.toDouble(), avg));
      j++;
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    if (widget.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
    );
  }
    final last = lastMeal;
    final spots = _spots;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.bg,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            radius: 22,
          backgroundImage: widget.user?.imageUrl == null
              ? const AssetImage("assets/images/default_user.jpg")
              : NetworkImage(widget.user!.imageUrl!) as ImageProvider,
          ),
        ),
        title: Text(
          'Hello, ${widget.user!.name}',
          style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_rounded,
                color: theme.textSecondary, size: 26),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: theme.textSecondary.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.user!.username}'s Progress",
                        style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _purple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _purple.withOpacity(0.3)),
                        ),
                        child: const Text("Weekly Mini Graph",
                            style: TextStyle(
                                color: _purple,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 170,
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: _purple))
                        : spots.isEmpty
                            ? Center(
                                child: Text("No data",
                                    style: TextStyle(
                                        color: theme.textSecondary,
                                        fontSize: 15)))
                            : LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: spots.length.toDouble() - 1,
                                  minY: 0,
                                  maxY: 100,
                                  clipData: const FlClipData.all(),
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      curveSmoothness: 0.35,
                                      barWidth: 3,
                                      gradient: const LinearGradient(
                                          colors: [_purple, _teal]),
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (s, p, b, i) =>
                                            FlDotCirclePainter(
                                          radius: 4,
                                          color: _purple,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        ),
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            _purple.withOpacity(0.2),
                                            _teal.withOpacity(0.02),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                  lineTouchData:
                                      const LineTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        interval: 25,
                                        getTitlesWidget: (value, meta) => Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx < 0 ||
                                              idx >= foodList.length) {
                                            return const SizedBox();
                                          }
                                          int interval = 1;
                                          if (foodList.length > 6) {
                                            interval =
                                                (foodList.length / 5).ceil();
                                          }
                                          if (idx % interval != 0) {
                                            return const SizedBox();
                                          }
                                          final d = foodList[idx].date!;
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Text(
                                              "${d.day}/${d.month}",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: theme.textSecondary),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Last Meal
            Text("LAST MEAL",
                style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8)),
            const SizedBox(height: 12),

            last == null
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: theme.textSecondary.withOpacity(0.15)),
                    ),
                    child: Center(
                      child: Text("No meal recorded",
                          style: TextStyle(
                              color: theme.textSecondary, fontSize: 15)),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: theme.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: theme.textSecondary.withOpacity(0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: _teal.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(24)),
                          child: Image.network(
                            last.imageUrl,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 130,
                              height: 130,
                              color: theme.textSecondary.withOpacity(0.08),
                              child: Icon(Icons.broken_image_rounded,
                                  color: theme.textSecondary, size: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${last.date!.day}/${last.date!.month}/${last.date!.year}",
                                  style: TextStyle(
                                      color: theme.textSecondary,
                                      fontSize: 12),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _nutrientChip(Icons.egg_rounded,
                                        "${last.protein.toStringAsFixed(1)}g",
                                        _purple),
                                    const SizedBox(width: 10),
                                    _nutrientChip(Icons.water_drop_rounded,
                                        "${last.fat.toStringAsFixed(1)}g",
                                        _pink),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _nutrientChip(
                                    Icons.local_fire_department_rounded,
                                    "${last.calories.toStringAsFixed(0)} kcal",
                                    Colors.orange),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                    ),
                  ),

            const SizedBox(height: 32),

            // Choose Picture Button
            GestureDetector(
              onTap: _processData,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [_purple, _teal]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_rounded,
                        color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text("Choose Picture",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Text("ADVICE",
                style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates_rounded,
                    color: Colors.orange.withOpacity(0.8),
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAdvice(last),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _nutrientChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _processData() async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 1024);
    if (pickedFile == null) return;
    Navigator.pushNamedAndRemoveUntil(
        context, '/main-screen', (_) => false,
        arguments: {
          'nutrientImage': pickedFile.path,
          'initializeIndex': 0
        });
  }

  Widget _buildAdvice(FoodNutrient? last) {
    final theme = context.watch<ThemeProvider>().current;
  if (last == null || last.advice.isEmpty) {
    return Text(
      "No advice available",
      style: TextStyle(
        fontSize: 15,
        color: theme.textPrimary,
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: last.advice.map((advice) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "•",
              style: TextStyle(
                fontSize: 18, 
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                advice,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: theme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
  }
}