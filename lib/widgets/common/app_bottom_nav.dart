import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        /// BARRA DE NAVEGACIÓN
        Container(
          height: 80 + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(
            color: Color(0xFF2F9C9C),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(context, Icons.home_outlined, "Inicio", AppRoutes.home),
              buildNavItem(context, Icons.people_outline, "Pacientes", AppRoutes.patients),
              const SizedBox(width: 60), // ESPACIO PARA EL BOTÓN CENTRAL
              buildNavItem(context, Icons.calendar_month_outlined, "Agenda", AppRoutes.agenda),
              buildNavItem(context, Icons.settings_outlined, "Opciones", AppRoutes.settings),
            ],
          ),
        ),

        /// BOTÓN CENTRAL DE EMERGENCIA
        Positioned(
          top: -30,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.emergency),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE74C3C).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 35),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNavItem(BuildContext context, IconData icon, String label, String route) {
    // Intentamos detectar la ruta actual para el estado activo (opcional)
    final bool isActive = ModalRoute.of(context)?.settings.name == route;

    return GestureDetector(
      onTap: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.black : Colors.white70,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white70,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

