import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'main.dart'; // QuoteScreen-এ যাওয়ার জন্য

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ৩.৫ সেকেন্ড পর মেইন স্ক্রিনে স্মুথ ফেড ট্রানজিশন করে চলে যাবে
    Future.delayed(const Duration(milliseconds: 3500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const QuoteScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF2C3E50);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ১. App Name (Playfair Display)
              Text(
                'Daily Zen',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: textColor,
                ),
              ).animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuad), // ওপর থেকে হালকা স্লাইড হয়ে আসবে

              const SizedBox(height: 50),

              // ২. App Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(35), // লোগোর কর্নারগুলো রাউন্ডেড করার জন্য
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ).animate(delay: 400.ms)
                  .scale(duration: 800.ms, curve: Curves.easeOutBack) // পপ আপ ইফেক্ট
                  .fadeIn(duration: 800.ms),

              const Spacer(flex: 3),

              // ৩. Footer Text (Inter)
              Text(
                'Made with ❤️ by Shakinul',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7F8C8D),
                  letterSpacing: 0.5,
                ),
              ).animate(delay: 1200.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad), // নিচ থেকে হালকা স্লাইড হয়ে আসবে

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}