import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:freelance_app/models/job_model.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, int> bidOverview;
  final bool overviewLoading;
  final String? overviewError;
  final List<Job> suggestedJobs;
  final Function(int) onNavigate;

  const DashboardScreen({
    super.key,
    required this.bidOverview,
    required this.overviewLoading,
    required this.overviewError,
    required this.suggestedJobs,
    required this.onNavigate,
  });

  double get totalProposals => (bidOverview['totalProposals'] ?? 0).toDouble();
  double get pendingCount => (bidOverview['pendingCount'] ?? 0).toDouble();
  double get inProgressCount => (bidOverview['inProgressCount'] ?? 0).toDouble();
  double get deliveredNotPaidCount => (bidOverview['deliveredNotPaidCount'] ?? 0).toDouble();
  double get completedCount => (bidOverview['completedCount'] ?? 0).toDouble();
  double get rejectedCount => (bidOverview['rejectedCount'] ?? 0).toDouble();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 60, runSpacing: 50, children: [
          _quickAction(Icons.search, "Browse", Colors.teal, () => onNavigate(1)),
          _quickAction(Icons.list_alt, "My Bids", Colors.purple, () => onNavigate(2)),
          _quickAction(Icons.assignment, "My Jobs", Colors.deepPurple, () => onNavigate(3)),
          _quickAction(Icons.account_balance_wallet, "Wallet", Colors.green, () => onNavigate(-1)),
        ]),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Proposals Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: _buildBarChartOrLoader(),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: screenWidth * 0.36,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text("Status Split", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(height: 140, child: _buildPieChartOrLoader()),
                      const SizedBox(height: 8),
                      _legendRow()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text("Activity Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _summaryTile("Proposals", totalProposals.toInt().toString(), Icons.send, Colors.teal),
          _summaryTile("Pending", pendingCount.toInt().toString(), Icons.hourglass_empty, Colors.orange),
          _summaryTile("In Progress", inProgressCount.toInt().toString(), Icons.timelapse, Colors.deepPurple),
          _summaryTile("Delivered (Not Paid)", deliveredNotPaidCount.toInt().toString(), Icons.delivery_dining, Colors.blue),
          _summaryTile("Completed", completedCount.toInt().toString(), Icons.check_circle, Colors.green),
          _summaryTile("Rejected", rejectedCount.toInt().toString(), Icons.cancel, Colors.red),
        ]),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Suggested Jobs", style: Theme.of(context).textTheme.titleLarge),
          TextButton(onPressed: () => onNavigate(1), child: const Text("See all")),
        ]),
        const SizedBox(height: 12),
        _suggestedJobsPreview()
      ]),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildBarChartOrLoader() {
    if (overviewLoading) return const Center(child: CircularProgressIndicator());
    if (overviewError != null) return Center(child: Text(overviewError!, style: const TextStyle(color: Colors.red)));

    final maxY = [
      totalProposals,
      pendingCount,
      inProgressCount,
      completedCount
    ].fold<double>(1.0, (prev, el) => el > prev ? el : prev);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxY < 1 ? 1 : maxY) + (maxY * 0.2),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 0:
                  return const Text("Proposals", style: TextStyle(fontSize: 10));
                case 1:
                  return const Text("Pending", style: TextStyle(fontSize: 10));
                case 2:
                  return const Text("Progress", style: TextStyle(fontSize: 10));
                case 3:
                  return const Text("Completed", style: TextStyle(fontSize: 10));
              }
              return const Text('');
            }),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalProposals, width: 18, color: Colors.teal)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: pendingCount, width: 18, color: Colors.orange)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: inProgressCount, width: 18, color: Colors.deepPurple)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: completedCount, width: 18, color: Colors.green)]),
        ],
      ),
    );
  }

  Widget _buildPieChartOrLoader() {
    if (overviewLoading) return const Center(child: CircularProgressIndicator());
    if (overviewError != null) return Center(child: Text(overviewError!, style: const TextStyle(color: Colors.red)));

    final total = pendingCount + inProgressCount + deliveredNotPaidCount + completedCount + rejectedCount;
    if (total <= 0) return const Center(child: Text("No data"));

    final sections = <PieChartSectionData>[
      PieChartSectionData(value: pendingCount, color: Colors.orange, title: ''),
      PieChartSectionData(value: inProgressCount, color: Colors.deepPurple, title: ''),
      PieChartSectionData(value: deliveredNotPaidCount, color: Colors.blue, title: ''),
      PieChartSectionData(value: completedCount, color: Colors.green, title: ''),
      PieChartSectionData(value: rejectedCount, color: Colors.red, title: ''),
    ];

    return PieChart(PieChartData(sections: sections, centerSpaceRadius: 28, sectionsSpace: 2));
  }

  Widget _legendRow() {
    return Wrap(spacing: 8, runSpacing: 4, alignment: WrapAlignment.center, children: [
      _legendItem(Colors.orange, "Pending"),
      _legendItem(Colors.deepPurple, "In Progress"),
      _legendItem(Colors.blue, "Delivered"),
      _legendItem(Colors.green, "Completed"),
      _legendItem(Colors.red, "Rejected"),
    ]);
  }

  Widget _legendItem(Color c, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }

  Widget _summaryTile(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
          ]),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ]),
      ),
    );
  }

  Widget _suggestedJobsPreview() {
    if (suggestedJobs.isEmpty) return const Text("No jobs available.");

    final preview = suggestedJobs.take(3).toList();
    return Column(
      children: preview.map((job) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Budget: \$${job.budget.toStringAsFixed(2)}\nDeadline: ${job.deadline}"),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text("Apply"),
            ),
          ),
        );
      }).toList(),
    );
  }
}
