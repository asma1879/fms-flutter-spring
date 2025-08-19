import 'package:flutter/material.dart';
import 'package:freelance_app/providers/bid_provider.dart';
import 'package:freelance_app/providers/notification_provider.dart';
import 'package:freelance_app/screens/FreelancerReviewsScreen.dart';
import 'package:freelance_app/screens/freelancers_wallet_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your screens here:
import 'screens/login_screen.dart';
import 'screens/ClientHomeScreen.dart';
import 'screens/FreelancerHomeScreen.dart';
//import 'screens/freelancer_wallet_screen.dart';
import 'screens/freelancer_withdrawal_table.dart';
import 'screens/freelancer_withdraw_screen.dart';
import 'screens/freelancer_home_report_screen.dart';
import 'screens/wallet_report.dart';
import 'screens/wishlist_screen.dart';
//import 'screens/freelancer_reviews_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BidProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    final name = prefs.getString('userName');

    if (role == 'CLIENT') {
      return ClientHomeScreen(username: name ?? 'Client');
    } else if (role == 'FREELANCER') {
      return FreelancerHomeScreen(username: name ?? 'Freelancer');
    } else {
      return const LoginScreen();
    }
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/freelancersWallet':
        return MaterialPageRoute(builder: (_) => const FreelancerWalletScreen());

      case '/freelancerWithdrawalTable':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => FreelancerWithdrawalTableScreen(freelancerId: args),
          );
        }
        return _errorRoute();

      case '/freelancerWithdraw':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => FreelancerWithdrawScreen(freelancerId: args),
          );
        }
        return _errorRoute();

      case '/freelancerReports':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => FreelancerReportScreen(freelancerId: args),
          );
        }
        return _errorRoute();

      case '/walletReport':
        return MaterialPageRoute(builder: (_) => WalletReportScreen());

      case '/wishlist':
        if (args is int) {
          return MaterialPageRoute(builder: (_) => WishlistScreen(userId: args));
        }
        return _errorRoute();

      case '/freelancerReviews':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => FreelancerReviewsScreen(freelancerId: args),
          );
        }
        return _errorRoute();

      default:
        return null;
    }
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Route error: invalid arguments or unknown route")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freelancing App',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
