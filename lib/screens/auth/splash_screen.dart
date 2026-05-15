import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Consultar el rol antes de decidir a dónde ir
        final role = await UserService.getUserRole();
        if (mounted) {
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        }
      } else {
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png", height: 140),

            const SizedBox(height: 20),

            Image.asset("assets/nombre_logo.png", height: 50),
          ],
        ),
      ),
    );
  }
}
