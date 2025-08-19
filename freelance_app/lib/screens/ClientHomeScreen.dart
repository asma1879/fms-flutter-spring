import 'package:flutter/material.dart';
import 'package:freelance_app/screens/add_fund_screen.dart';
import 'package:freelance_app/screens/charts_dashboard.dart';
import 'package:freelance_app/screens/client_delivered_bid_screen.dart';
import 'package:freelance_app/screens/client_post_job_screen.dart';
import 'package:freelance_app/screens/client_posted_jobs_screen.dart';
import 'package:freelance_app/screens/client_review_screen.dart';
import 'package:freelance_app/screens/freelancer_page.dart';
import 'package:freelance_app/screens/login_screen.dart';
import 'package:freelance_app/screens/wallet_report.dart';
import 'package:freelance_app/services/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------- ClientHomeScreen ----------------
class ClientHomeScreen extends StatefulWidget {
  final String username;
  const ClientHomeScreen({super.key, required this.username});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  double walletBalance = 0.0;
  bool loading = true;
  int? clientId;
  final WalletService walletService = WalletService();
  int _selectedIndex = 0;

  final ChartsDashboard charts = ChartsDashboard();

  final Color primaryColor = Color(0xFF2C3E50);
  final Color secondaryColor = Color(0xFF34495E);
  final Color accentColor = Color(0xFF3498DB);
  final Color backgroundColor = Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _loadClientWallet();
  }

  Future<void> _loadClientWallet() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    clientId = prefs.getInt('userId');

    if (clientId != null) {
      try {
        double balance = await walletService.getUserWallet(clientId!);
        setState(() {
          walletBalance = balance;
          loading = false;
        });
      } catch (_) {
        setState(() {
          walletBalance = 0.0;
          loading = false;
        });
      }
    } else {
      setState(() => loading = false);
    }
  }

  List<int> _history = [];

void _onItemTapped(int index) {
  if (_selectedIndex != index) {
    _history.add(_selectedIndex); // save current page before switching
    setState(() => _selectedIndex = index);
  }
}

void _onBackPressed() {
  if (_history.isNotEmpty) {
    setState(() => _selectedIndex = _history.removeLast());
  } else {
    Navigator.pop(context); // exit app if no history
  }
}

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  //void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Widget _buildDrawer() {
    final items = [
      {'icon': Icons.dashboard, 'label': 'Overview'},
      {'icon': Icons.group, 'label': 'Freelancers'},
      {'icon': Icons.payment, 'label': 'Payments'},
      {'icon': Icons.post_add, 'label': 'Post Job'},
      {'icon': Icons.list_alt, 'label': 'My Jobs'},
      {'icon': Icons.delivery_dining, 'label': 'Delivered Bids'},
      {'icon': Icons.rate_review, 'label': 'Reviews'},
      {'icon': Icons.bar_chart, 'label': 'Charts'},
      {'icon': Icons.account_balance_wallet, 'label': 'Wallet Report'},
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.business, color: primaryColor, size: 40),
                ),
                SizedBox(height: 12),
                Text(widget.username,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Client Dashboard",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    )),
              ],
            ),
          ),
          ...List.generate(items.length, (index) {
            final selected = _selectedIndex == index;
            return ListTile(
              leading: Icon(items[index]['icon'] as IconData,
                  color: selected ? accentColor : Colors.grey[600]),
              title: Text(
                items[index]['label'] as String,
                style: TextStyle(
                    color: selected ? accentColor : textColor,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal),
              ),
              selected: selected,
              selectedTileColor: accentColor.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(index);
              },
            );
          }),
          Divider(height: 1, color: Colors.grey),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.grey[700]),
            title: Text("Logout", style: TextStyle(color: textColor)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      OverviewPage(
        username: widget.username,
        walletBalance: walletBalance,
        loading: loading,
        clientId: clientId,
        loadWalletCallback: _loadClientWallet,
        logoutCallback: () => _logout(context),
        charts: charts,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        accentColor: accentColor,
        cardColor: cardColor,
        textColor: textColor,
        onQuickActionTap: _onItemTapped, // Pass navigation callback
      ),
      FreelancersPage(),
      PaymentsPage(),
      ClientPostJobScreen(),
      ClientPostedJobsScreen(),
      clientId != null
          ? ClientDeliveredBidsScreen(
              clientId: clientId!, onPaymentConfirmed: _loadClientWallet)
          : Center(child: CircularProgressIndicator()),
      clientId != null
          ? ClientReviewsScreen(clientId: clientId!)
          : Center(child: CircularProgressIndicator()),
      charts,
      WalletReportScreen(),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      endDrawer: _buildDrawer(),
      appBar: AppBar(
  backgroundColor: primaryColor,
  elevation: 2,
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
   onPressed: _onBackPressed,
  ),
  title: Text(
    "Welcome, ${widget.username}!",
    style: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
  ),
  iconTheme: IconThemeData(color: Colors.white),
  actions: [
    IconButton(
      icon: Icon(Icons.notifications_none, size: 26),
      tooltip: 'Notifications',
      onPressed: () {},
    ),
    // Drawer button moved to the right
    Builder(
      builder: (context) => IconButton(
        icon: Icon(Icons.menu),
        tooltip: 'Menu',
        onPressed: () => Scaffold.of(context).openEndDrawer(),
      ),
    ),
    IconButton(
      icon: Icon(Icons.logout, size: 26),
      tooltip: 'Logout',
      onPressed: () => _logout(context),
    ),
    
    SizedBox(width: 8),
  ],
),

      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 5,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Overview"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Freelancers"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments"),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: "Post Job"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "My Jobs"),
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: "Delivered"),
          BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: "Reviews"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Charts"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
        ],
      ),
    );
  }
}

// ---------------- OverviewPage ----------------
class OverviewPage extends StatelessWidget {
  final String username;
  final double walletBalance;
  final bool loading;
  final int? clientId;
  final Future<void> Function() loadWalletCallback;
  final VoidCallback logoutCallback;
  final ChartsDashboard charts;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color cardColor;
  final Color textColor;
  final void Function(int index) onQuickActionTap; // callback

  const OverviewPage({
    super.key,
    required this.username,
    required this.walletBalance,
    required this.loading,
    required this.clientId,
    required this.loadWalletCallback,
    required this.logoutCallback,
    required this.charts,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.cardColor,
    required this.textColor,
    required this.onQuickActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWalletCard(context),
          SizedBox(height: 24),
          _buildQuickActions(context),
          SizedBox(height: 24),
          Expanded(child: charts),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      shadowColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.account_balance_wallet_outlined,
                  size: 28, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(
              child: loading
                  ? Text("Loading wallet balance...", style: TextStyle(color: textColor))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Wallet Balance",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        SizedBox(height: 6),
                        Text("\$${walletBalance.toStringAsFixed(2)}",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                      ],
                    ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AddFundScreen()));
                await loadWalletCallback();
              },
              icon: Icon(Icons.add, size: 18),
              label: Text("Add Funds"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildQuickActions(BuildContext context) {
  final actions = [
    {'icon': Icons.post_add, 'label': 'Post Job', 'color': accentColor, 'index': 3},
    {'icon': Icons.list_alt, 'label': 'My Jobs', 'color': Color(0xFFE74C3C), 'index': 4},
    {'icon': Icons.delivery_dining, 'label': 'Delivered', 'color': Color(0xFF2ECC71), 'index': 5},
    {'icon': Icons.rate_review, 'label': 'Reviews', 'color': Color(0xFFF39C12), 'index': 6},
    {'icon': Icons.account_balance_wallet, 'label': 'Wallet Report', 'color': Color(0xFF9B59B6), 'index': 8},
  ];

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(right: 40), // spacing between buttons
          child: _quickActionButton(
            context,
            action['icon'] as IconData,
            action['label'] as String,
            action['color'] as Color,
            action['index'] as int,
          ),
        );
      }).toList(),
    ),
  );
}

Widget _quickActionButton(BuildContext context, IconData icon, String label, Color color, int index) {
  return InkWell(
    onTap: () {
      onQuickActionTap(index);
    },
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 80,   // smaller width
      height: 80,  // smaller height
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24), // smaller icon
          SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 12, // smaller font
              )),
        ],
      ),
    ),
  );
}

}
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Payments Page"));
}
