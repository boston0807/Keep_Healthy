import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:keep_healthy/models/food_nutrient.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../config/theme_config.dart';

enum ViewMode { daily, weekly, monthly }

class GraphPage extends StatefulWidget {
  final List<FoodNutrient> foodListRef;
  final int usageCount;

  const GraphPage(
      {super.key, required this.foodListRef, required this.usageCount});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  ViewMode _viewMode = ViewMode.daily;

  static const _accent1 = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF00D4AA);
  static const _accent3 = Color(0xFFFF7B9C);

  List<FoodNutrient> get _sorted {
    final s = List<FoodNutrient>.from(widget.foodListRef);
    s.sort((a, b) => a.date!.compareTo(b.date!));
    return s;
  }

  List<_DataPoint> get _aggregated {
    final sorted = _sorted;
    if (sorted.isEmpty) return [];

    switch (_viewMode) {
      case ViewMode.daily:
        return sorted.map((f) {
          final d = f.date!;
          return _DataPoint("${d.hour}:${d.minute}", f.point);
        }).toList();

      case ViewMode.weekly:
        final now = DateTime.now();
        final start = now.subtract(const Duration(days: 6));

        final Map<String, List<double>> groups = {};

        for (final f in sorted) {
          final d = f.date!;
          
          if (d.isAfter(start.subtract(const Duration(days: 1))) &&
              d.isBefore(now.add(const Duration(days: 1)))) {

            final key = "${d.day}/${d.month}";
            groups.putIfAbsent(key, () => []);
            groups[key]!.add(f.point);
          }
        }

        final keys = groups.keys.toList();

        return keys.map((k) {
          final avg = groups[k]!.reduce((a, b) => a + b) / groups[k]!.length;
          return _DataPoint(k, avg);
        }).toList();

      case ViewMode.monthly:
        final Map<int, List<double>> groups = {};
        final Map<int, String> labels = {};
        const months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        for (final f in sorted) {
          final d = f.date!;
          final key = d.year * 100 + d.month;
          groups.putIfAbsent(key, () => []);
          groups[key]!.add(f.point);
          labels.putIfAbsent(
              key, () => "${months[d.month]}\n${d.year.toString().substring(2)}");
        }
        final keys = groups.keys.toList()..sort();
        return keys.map((k) {
          final avg = groups[k]!.reduce((a, b) => a + b) / groups[k]!.length;
          return _DataPoint(labels[k]!, avg);
        }).toList();
    }
  }

  int _isoWeekKey(DateTime d) => d.year * 100 + _isoWeek(d);

  int _isoWeek(DateTime d) {
    final startOfYear = DateTime(d.year, 1, 1);
    final diff = d.difference(startOfYear).inDays;
    return ((diff + startOfYear.weekday - 1) / 7).floor() + 1;
  }

  @override
  Widget build(BuildContext context) {

    final theme = context.watch<ThemeProvider>().current;
    final data = _aggregated;
    final isEmpty = data.isEmpty;

    final double maxPoint =
        isEmpty ? 100 : FoodNutrient.maxPoint(widget.foodListRef);
    final double minPoint =
        isEmpty ? 0 : FoodNutrient.minPoint(widget.foodListRef);
    final double avg = isEmpty
        ? 0
        : widget.foodListRef.map((f) => f.point).reduce((a, b) => a + b) /
            widget.foodListRef.length;

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.point);
    }).toList();

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        iconTheme: IconThemeData(color: theme.textPrimary),
        backgroundColor: theme.bg,
        elevation: 0,
        title: Text(
          "Health Score",
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isEmpty
          ? _emptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ViewToggle(
                    current: _viewMode,
                    onChanged: (v) => setState(() => _viewMode = v),
                  ),
                  const SizedBox(height: 18),
                  _ChartCard(spots: spots, data: data),
                  const SizedBox(height: 20),
                  _SectionLabel(
                    label: _viewMode == ViewMode.daily
                        ? "DAILY SUMMARY"
                        : _viewMode == ViewMode.weekly
                            ? "WEEKLY SUMMARY"
                            : "MONTHLY SUMMARY",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MiniStat(
                        label: "Best",
                        value: maxPoint.toStringAsFixed(1),
                        icon: Icons.emoji_events_rounded,
                        color: _accent2,
                      ),
                      const SizedBox(width: 10),
                      _MiniStat(
                        label: "Lowest",
                        value: minPoint.toStringAsFixed(1),
                        icon: Icons.trending_down_rounded,
                        color: _accent3,
                      ),
                      const SizedBox(width: 10),
                      _MiniStat(
                        label: "Average",
                        value: avg.toStringAsFixed(1),
                        icon: Icons.bar_chart_rounded,
                        color: _accent1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _accent1.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calculate_rounded,
                                color: _accent1, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Calculations",
                                style: TextStyle(
                                  color: theme.textPrimary.withOpacity(0.45),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${widget.usageCount} times",
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
    );
  }

  Widget _emptyState() {
    final theme = context.watch<ThemeProvider>().current;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 64, color: theme.textPrimary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("No data yet",
              style: TextStyle(
                  color: theme.textPrimary.withOpacity(0.4),
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DataPoint {
  final String label;
  final double point;
  const _DataPoint(this.label, this.point);
}

class _ViewToggle extends StatelessWidget {
  final ViewMode current;
  final ValueChanged<ViewMode> onChanged;

  const _ViewToggle({required this.current, required this.onChanged});

  static const _accent1 = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.textPrimary.withOpacity(0.08)),
      ),
      child: Row(
        children: ViewMode.values.map((mode) {
          final selected = mode == current;
          final label = mode == ViewMode.daily
              ? "Daily"
              : mode == ViewMode.weekly
                  ? "Weekly"
                  : "Monthly";
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? theme.textPrimary
                        : theme.textPrimary.withOpacity(0.45),
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<FlSpot> spots;
  final List<_DataPoint> data;

  const _ChartCard({required this.spots, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.textPrimary.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: spots.isEmpty ? 1 : spots.length.toDouble() - 1,
            minY: 0,
            maxY: 100,
            clipData: const FlClipData.all(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (v) => FlLine(
                color: Colors.white.withOpacity(0.06),  // ***NOT SURE IF NEED TO FIX OR NAH***
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 80,
                  dashArray: [6, 4],
                  color: const Color(0xFF00D4AA),
                  strokeWidth: 1.2,
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topLeft,
                    labelResolver: (_) => "  Excellent",
                    style: const TextStyle(
                      color: Color(0xFF00D4AA),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                HorizontalLine(
                  y: 50,
                  dashArray: [6, 4],
                  color: Colors.orange.withOpacity(0.7),
                  strokeWidth: 1.2,
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topLeft,
                    labelResolver: (_) => "  Average",
                    style: TextStyle(
                      color: Colors.orange.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                barWidth: 3,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                ),
                dotData: FlDotData(
                  show: spots.length <= 12,
                  getDotPainter: (spot, pct, bar, idx) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF6C63FF),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.25),
                      const Color(0xFF00D4AA).withOpacity(0.02),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: const Color(0xFF1A1F35),
                tooltipBorder: const BorderSide(
                    color: Color(0xFF6C63FF), width: 1),
                getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                  return LineTooltipItem(
                    s.y.toStringAsFixed(1),
                    const TextStyle(
                      color: Color(0xFF00D4AA),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= data.length) {
                      return const SizedBox();
                    }
                    int interval = 1;
                    if (data.length > 7) {
                      interval = (data.length / 6).ceil();
                    }
                    if (idx % interval != 0) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        data[idx].label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.45),
                          height: 1.3,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 25,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: theme.textPrimary.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Container(
      decoration: BoxDecoration(
        color: theme.textPrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.textPrimary.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    return Text(
      label,
      style: TextStyle(
        color: theme.textPrimary.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
      ),
    );
  }
}