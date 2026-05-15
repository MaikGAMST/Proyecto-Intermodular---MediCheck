import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const AppHeader({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BOTÓN PERFIL
          IconButton(
            icon: const Icon(Icons.person_outline, size: 32),
            onPressed: onProfileTap,
          ),

          // NOMBRE APP
          Image.asset("assets/nombre_logo.png", height: 30),

          // LOGO
          Image.asset("assets/logo.png", height: 36),
        ],
      ),
    );
  }
}
