import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bid_provider.dart';
import '../models/bid_model.dart';

class FreelancerReportScreen extends StatefulWidget {
  final int freelancerId;
  const FreelancerReportScreen({Key? key, required this.freelancerId}) : super(key: key);

  @override
  State<FreelancerReportScreen> createState() => _FreelancerReportScreenState();
}

class _FreelancerReportScreenState extends State<FreelancerReportScreen> {
  bool _isLoading = false;

  // Sorting variables
  int? _sortColumnIndex;
  bool _isAscending = true;
  List<Bid> _sortedBids = [];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<BidProvider>(context, listen: false);
    await provider.loadAllBidsForFreelancer(widget.freelancerId);
    setState(() {
      _sortedBids = List.from(provider.bids); // Initial sort data
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freelancer Work Report'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<BidProvider>(
              builder: (context, provider, _) {
                final allBids = _sortedBids;

                // ✅ Counts calculated from the same list used in table
                final deliveredCount = allBids
                    .where((b) => (b.deliveryStatus ?? "").toLowerCase() == "delivered")
                    .length;
                final acceptedCount = allBids
                    .where((b) => (b.status ?? "").toUpperCase() == "ACCEPTED")
                    .length;
                final paidCount = allBids
                    .where((b) => (b.status ?? "").toUpperCase() == "PAID")
                    .length;
                final pendingCount = allBids
                    .where((b) =>
                        (b.status ?? "").toUpperCase() == "PENDING" || b.status == null)
                    .length;

                return RefreshIndicator(
                  onRefresh: _loadReportData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(deliveredCount, acceptedCount, paidCount, pendingCount),
                        const SizedBox(height: 24),
                        Text('All Jobs', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        if (allBids.isEmpty)
                          const Center(child: Text("No bids found."))
                        else
                          _buildBidsTable(allBids),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSummaryCards(int delivered, int accepted, int paid, int pending) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _summaryCard('Delivered', delivered, Colors.green),
        _summaryCard('Accepted', accepted, Colors.blue),
        _summaryCard('Paid', paid, Colors.teal),
        _summaryCard('Pending', pending, Colors.orange),
      ],
    );
  }

  Widget _summaryCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.08),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBidsTable(List<Bid> bids) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _isAscending,
          headingRowColor: MaterialStateProperty.all(Colors.deepPurple.shade50),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          dataTextStyle: const TextStyle(fontSize: 14),
          border: TableBorder.symmetric(
            inside: BorderSide(width: 0.5, color: Colors.grey.shade300),
            outside: BorderSide(width: 1, color: Colors.grey.shade300),
          ),
          columns: [
            DataColumn(
              label: const Text("Job Title"),
              onSort: (columnIndex, ascending) {
                _onSort<String>(
                  columnIndex,
                  ascending,
                  (bid) => bid.job?.title ?? "",
                );
              },
            ),
            DataColumn(
              label: const Text("Status"),
              onSort: (columnIndex, ascending) {
                _onSort<String>(
                  columnIndex,
                  ascending,
                  (bid) => bid.status ?? "",
                );
              },
            ),
            DataColumn(
              label: const Text("Delivery"),
              onSort: (columnIndex, ascending) {
                _onSort<String>(
                  columnIndex,
                  ascending,
                  (bid) => bid.deliveryStatus ?? "",
                );
              },
            ),
            DataColumn(
              label: const Text("Amount"),
              numeric: true,
              onSort: (columnIndex, ascending) {
                _onSort<num>(
                  columnIndex,
                  ascending,
                  (bid) => bid.amount,
                );
              },
            ),
          ],
          rows: bids.map((bid) {
            final statusColor = _getStatusColor(bid.status ?? "");
            final deliveryStatus = bid.deliveryStatus ?? "Not Delivered";
            final deliveryColor = deliveryStatus.toLowerCase() == "delivered"
                ? Colors.green
                : Colors.orange;

            return DataRow(
              cells: [
                DataCell(Text(bid.job?.title ?? bid.jobTitle ?? "No Job Title",)),
                DataCell(
                  Text(
                    bid.status ?? "Unknown",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    deliveryStatus,
                    style: TextStyle(
                      color: deliveryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(Text("\$${bid.amount.toStringAsFixed(2)}")),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onSort<T>(
    int columnIndex,
    bool ascending,
    Comparable<T> Function(Bid bid) getField,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
      _sortedBids.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return Colors.blue;
      case 'PAID':
        return Colors.teal;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
