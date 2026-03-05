import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:keep_healthy/models/food_nutrient.dart';

class GraphPage extends StatelessWidget {
  final List<FoodNutrient> foodListRef;

  const GraphPage({super.key, required this.foodListRef});

  @override
  Widget build(BuildContext context) {
    if (foodListRef.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No data")),
      );
    }

    List<FoodNutrient> sorted = List.from(foodListRef);
    sorted.sort((a, b) => a.date!.compareTo(b.date!));

    List<FlSpot> spots = [];
    int i = 0;
    while (i < sorted.length) {
      spots.add(FlSpot(i.toDouble(), sorted[i].point));
      i++;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Score Overview"),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: 340,   
              height: 200,  
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: spots.length.toDouble() - 1,
                  minY: 0,
                  maxY: 100,

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 80,
                        dashArray: [6, 4],
                        color: Colors.green,
                        strokeWidth: 1,
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topLeft,
                          labelResolver: (line) => "Excellent",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      HorizontalLine(
                        y: 50,
                        dashArray: [6, 4],
                        color: Colors.orange,
                        strokeWidth: 1,
                      ),
                    ],
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= sorted.length) {
                            return const SizedBox();
                          }

                          int interval = 1;
                          if (sorted.length > 6) {
                            interval = (sorted.length / 6).ceil();
                          }

                          if (index % interval != 0) {
                            return const SizedBox();
                          }

                          DateTime date = sorted[index].date!;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "${date.day}/${date.month}",
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      )
    );
  }
}