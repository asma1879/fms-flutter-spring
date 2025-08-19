import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:freelance_app/models/job_model.dart';
import 'package:freelance_app/screens/FreelancerReviewsScreen.dart';
import 'package:freelance_app/screens/browse_jobs_screen.dart';
import 'package:freelance_app/screens/freelancer_bids_screen.dart';
import 'package:freelance_app/screens/freelancer_dashboard_scree.dart';
import 'package:freelance_app/screens/freelancer_home_report_screen.dart';
import 'package:freelance_app/screens/freelancer_profile_screen.dart';
import 'package:freelance_app/screens/freelancers_home_job_screen.dart';
import 'package:freelance_app/screens/freelancers_wallet_screen.dart';
import 'package:freelance_app/screens/freelancer_withdraw_screen.dart';
import 'package:freelance_app/screens/freelancer_withdrawal_table.dart';
import 'package:freelance_app/screens/login_screen.dart';
import 'package:freelance_app/screens/my_job_screen.dart';
import 'package:freelance_app/screens/wallet_report.dart';
import 'package:freelance_app/screens/wishlist_screen.dart';
import 'package:freelance_app/services/bid_service.dart';
import 'package:freelance_app/services/job_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreelancerHomeScreen extends StatefulWidget {
  final String username;
  const FreelancerHomeScreen({super.key, required this.username});

  @override
  State<FreelancerHomeScreen> createState() => _FreelancerHomeScreenState();
}

class _FreelancerHomeScreenState extends State<FreelancerHomeScreen> {
  int _selectedIndex = 0;
  int _userId = 0;
  List<Job> _suggestedJobs = [];
  bool _isLoading = true;

  Map<String, int> _bidOverview = {};
  bool _overviewLoading = true;
  String? _overviewError;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndJobs();
  }

  Future<void> _loadUserDataAndJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId') ?? 0;

    try {
      final jobs = await JobService().getAllJobs();
      setState(() {
        _userId = id;
        _suggestedJobs = jobs;
        _isLoading = false;
      });
      await _loadBidOverview(id);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _overviewError = "Failed to load jobs or overview";
      });
    }
  }

  Future<void> _loadBidOverview(int freelancerId) async {
    setState(() {
      _overviewLoading = true;
      _overviewError = null;
    });
    try {
      final overview = await BidService().getBidOverview(freelancerId);
      setState(() {
        _bidOverview = overview;
        _overviewLoading = false;
      });
    } catch (e) {
      setState(() {
        _overviewError = "Failed to load overview";
        _overviewLoading = false;
      });
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


  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  // All screens including bottom nav + menu options.
  List<Widget> get _screens => [
        DashboardScreen(
          bidOverview: _bidOverview,
          overviewLoading: _overviewLoading,
          overviewError: _overviewError,
          suggestedJobs: _suggestedJobs,
          onNavigate: _navigateToIndex,
        ), // 0
        //HomeJobsScreen(jobs: _suggestedJobs), // 1
        BrowseJobsScreen(),//1
        FreelancerBidsScreen(freelancerId: _userId), // 2
        MyJobsScreen(freelancerId: _userId), // 3
        FreelancerProfileScreen(userId: _userId), // 4
        const FreelancerWalletScreen(), // 5
        FreelancerWithdrawScreen(freelancerId: _userId), // 6
        FreelancerWithdrawalTableScreen(freelancerId: _userId), // 7
        FreelancerReportScreen(freelancerId: _userId), // 8
        const WalletReportScreen(), // 9
        WishlistScreen(userId: _userId), // 10
        FreelancerReviewsScreen(freelancerId: _userId), // 11
      ];

  void _navigateToIndex(int index) {
    // This method is used by Dashboard quick actions or elsewhere
    if (index == -1) {
      // For example, Dashboard's Wallet quick action can call this with -1
      index = 5; // Wallet screen index
    }
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onSelectOverflow(BuildContext context, String choice) {
    switch (choice) {
      case 'Wallet':
        _navigateToIndex(5);
        break;
      case 'Withdraw':
        _navigateToIndex(6);
        break;
      case 'History':
        _navigateToIndex(7);
        break;
      case 'Reports':
        _navigateToIndex(8);
        break;
      case 'Wallet Report':
        _navigateToIndex(9);
        break;
      case 'Wishlist':
        _navigateToIndex(10);
        break;
      case 'Reviews':
        _navigateToIndex(11);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFFD6CFC7),
         leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
       onPressed: _onBackPressed,
      ),
        title: Text("Hello, ${widget.username} 👋"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
          PopupMenuButton<String>(
            onSelected: (choice) => _onSelectOverflow(context, choice),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Wallet',
                child: Row(
                  children: const [
                    Icon(Icons.account_balance_wallet, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Wallet'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Withdraw',
                child: Row(
                  children: const [
                    Icon(Icons.money_off, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Withdraw'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'History',
                child: Row(
                  children: const [
                    Icon(Icons.history, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Withdrawal History'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Reports',
                child: Row(
                  children: const [
                    Icon(Icons.insert_chart, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Reports'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Wallet Report',
                child: Row(
                  children: const [
                    Icon(Icons.pie_chart_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Wallet Report'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Wishlist',
                child: Row(
                  children: const [
                    Icon(Icons.favorite_border, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Wishlist'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Reviews',
                child: Row(
                  children: const [
                    Icon(Icons.rate_review, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text('Reviews'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex, // If on menu screen >4, reset bottom nav selection
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          _onItemTapped(index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          //BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: "Browse"),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: "Browse"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "My Bids"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: "My Jobs"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
