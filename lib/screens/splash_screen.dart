import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../theme/app_colors.dart';
import '../providers/meal_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    // Fetch meal data in background
    context.read<MealProvider>().fetchAll();

    // Wait for splash to show
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is already logged in via Firebase
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in — update AuthProvider status
      await context.read<AuthProvider>().checkAuthStatus();

      if (!mounted) return;

      // Go to main screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // Not logged in — go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppColors.background,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'QuickBite',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Order food you love',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
