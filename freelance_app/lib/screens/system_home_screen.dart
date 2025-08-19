import 'package:flutter/material.dart';
import 'package:freelance_app/screens/add_fund_screen.dart';
import 'package:freelance_app/screens/client_delivered_bid_screen.dart';
import 'package:freelance_app/screens/client_post_job_screen.dart';
import 'package:freelance_app/screens/client_posted_jobs_screen.dart';
import 'package:freelance_app/screens/login_screen.dart';
import 'package:freelance_app/services/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemHomeScreen extends StatefulWidget {
  final String username;

  const SystemHomeScreen({super.key, required this.username});

  @override
  State<SystemHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<SystemHomeScreen> {
  double walletBalance = 0.0;
  bool loading = true;
  int? clientId;

  final WalletService walletService = WalletService();

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
      } catch (e) {
        setState(() {
          walletBalance = 0.0;
          loading = false;
        });
      }
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 132, 66),
        title: Text("Welcome, ${widget.username}!"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.business, color: Colors.deepPurple),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadClientWallet,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _buildWalletCard(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _sectionTitle("Posted Jobs"),
            const SizedBox(height: 8),
            _postedJobsCard(),
            const SizedBox(height: 24),
            _sectionTitle("Delivered Work & Payments"),
            const SizedBox(height: 8),
            _deliveredJobsCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Overview"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Freelancers"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments"),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(14),
              child: const Icon(Icons.account_balance_wallet_outlined, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: loading
                  ? const Text("Loading wallet balance...", style: TextStyle(fontSize: 16))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Wallet Balance", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(
                          "\$${walletBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFundScreen()));
                await _loadClientWallet();
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Funds"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 58, 183, 183),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickActionButton(Icons.post_add, "Post Job", Colors.deepPurple, () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientPostJobScreen()));
          // Optionally reload posted jobs or other data here
        }),
        _quickActionButton(Icons.list_alt, "My Jobs", Colors.pink, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientPostedJobsScreen()));
        }),
        _quickActionButton(Icons.delivery_dining, "Delivered", Colors.green, () {
          if (clientId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClientDeliveredBidsScreen(
                  clientId: clientId!,
                  onPaymentConfirmed: _loadClientWallet,
                ),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _quickActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              offset: const Offset(0, 3),
              blurRadius: 5,
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _postedJobsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        leading: const Icon(Icons.list_alt, color: Colors.deepPurple, size: 40),
        title: const Text(
          "View Posted Jobs",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        subtitle: const Text("Browse jobs you have posted."),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientPostedJobsScreen()));
        },
      ),
    );
  }

  Widget _deliveredJobsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        leading: const Icon(Icons.delivery_dining, color: Colors.deepPurple, size: 40),
        title: const Text(
          "Delivered Work & Payments",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        subtitle: const Text("Review delivered jobs and confirm payments."),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (clientId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClientDeliveredBidsScreen(
                  clientId: clientId!,
                  onPaymentConfirmed: _loadClientWallet,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Client ID not found.")),
            );
          }
        },
      ),
    );
  }
}
