import 'package:flutter/material.dart';
import 'package:freelance_app/screens/ClientHomeScreen.dart';
import 'package:freelance_app/screens/FreelancerHomeScreen.dart';
import 'package:freelance_app/screens/system_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
//import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String? error;

  void _handleLogin() async {
  try {
    final user = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // Now user is defined, so you can save session info
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id ?? 0); // Use ?? 0 if id is nullable
    await prefs.setString('userName', user.name);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('userRole', user.role);

    // Navigate based on role
    if (user.role == 'FREELANCER') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FreelancerHomeScreen(username: user.name)),
      );
    } else if (user.role == 'CLIENT') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ClientHomeScreen(username: user.name)),
      );
    }
      else if (user.role == 'SYSTEM') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SystemHomeScreen(username: user.name)),
      );
      
    } else {
      setState(() => error = 'Unknown role: ${user.role}');
    }
  } catch (e) {
    setState(() => error = '❌ ${e.toString()}');
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: size.width > 500 ? 400 : double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, size: 64, color: Colors.teal),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back',
                  style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to your freelance account',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                if (error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(error!, style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
