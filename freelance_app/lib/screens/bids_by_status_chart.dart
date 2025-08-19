import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:freelance_app/services/chart_service.dart';
//import 'chart_service.dart';

class BidsByStatusChart extends StatefulWidget {
  @override
  _BidsByStatusChartState createState() => _BidsByStatusChartState();
}

class _BidsByStatusChartState extends State<BidsByStatusChart> {
  final ChartService chartService = ChartService();
  List<dynamic> chartData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var data = await chartService.getBidsByStatus();
    setState(() {
      chartData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return PieChart(
      PieChartData(
        sections: chartData.map((item) {
          return PieChartSectionData(
            title: "${item['status']} (${item['count']})",
            value: double.parse(item['count'].toString()),
            color: item['status'] == "PENDING" ? Colors.orange :
                   item['status'] == "ACCEPTED" ? Colors.green : Colors.red,
          );
        }).toList(),
      ),
    );
  }
}
