import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChartsDashboard extends StatefulWidget {
  const ChartsDashboard({super.key});

  @override
  State<ChartsDashboard> createState() => _ChartsDashboardState();
}

class _ChartsDashboardState extends State<ChartsDashboard> {
  List<dynamic> jobsPerMonth = [];
  List<dynamic> bidsByStatus = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      // Jobs per month
      final jobsResponse = await http.get(
          Uri.parse("http://localhost:8080/api/auth/charts/jobs-per-month"));
      final jobsData = json.decode(jobsResponse.body) as Map<String, dynamic>;
      jobsPerMonth = jobsData.entries
          .map((e) => {'month': int.parse(e.key), 'count': e.value})
          .toList();

      // Bids by status
      final bidsResponse = await http.get(
          Uri.parse("http://localhost:8080/api/auth/charts/bids-by-status"));
      bidsByStatus = json.decode(bidsResponse.body) as List<dynamic>;

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // -------------------- Jobs Chart --------------------
  Widget _jobsChart() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) {
      return Center(child: Text(error, style: const TextStyle(color: Colors.red)));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Jobs Posted Per Month",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 220, // Slightly taller for visual balance
              child: BarChart(
                BarChartData(
                  barGroups: jobsPerMonth.map<BarChartGroupData>((item) {
                    int month = item['month'];
                    int count = item['count'];
                    return BarChartGroupData(
                      x: month,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          color: const Color(0xFF4A148C), // Deep purple
                          width: 12,
                          borderRadius: BorderRadius.circular(6),
                        )
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, _) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, _) {
                          final months = [
                            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                          ];
                          return Text(
                            value.toInt() >= 1 && value.toInt() <= 12
                                ? months[value.toInt() - 1]
                                : '',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Bids Chart --------------------
  Widget _bidsChart() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) {
      return Center(child: Text(error, style: const TextStyle(color: Colors.red)));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bids by Status",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 220, // Larger for labels
              child: PieChart(
                PieChartData(
                  sections: bidsByStatus.map<PieChartSectionData>((item) {
                    final status = item['status'];
                    final count = (item['count'] as num).toDouble();

                    // Professional color palette
                    final color = status == "PENDING"
                        ? const Color(0xFF03A9F4) // Calm Blue
                        : status == "ACCEPTED"
                            ? const Color(0xFF4CAF50) // Soft Green
                            : status == "REJECTED"
                                ? const Color(0xFFF44336) // Soft Red
                                : status == "PAID"
                                    ? const Color(0xFF8BC34A) // Muted Lime Green
                                    : status == "DELIVERED"
                                        ? const Color(0xFF9C27B0) // Elegant Purple
                                        : Colors.grey;

                    return PieChartSectionData(
                      color: color,
                      value: count,
                      radius: 120, // Larger slice radius
                      title: "$status\n${count.toInt()}",
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      titlePositionPercentageOffset: 0.55, // Better centering
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Build --------------------
  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: isWideScreen
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _jobsChart()),
                const SizedBox(width: 8),
                Expanded(child: _bidsChart()),
              ],
            )
          : Column(
              children: [
                _jobsChart(),
                const SizedBox(height: 8),
                _bidsChart(),
              ],
            ),
    );
  }
}
