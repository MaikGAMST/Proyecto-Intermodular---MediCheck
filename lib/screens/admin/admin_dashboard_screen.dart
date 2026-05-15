import 'package:flutter/material.dart';
import '../../widgets/common/app_layout.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administración"),
        backgroundColor: const Color(0xFF2F9C9C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            buildAdminCard(
              context, 
              "Gestionar Cuidadores", 
              Icons.people_alt_rounded, 
              Colors.blueAccent,
              () => Navigator.pushNamed(context, AppRoutes.adminCaregivers),
            ),
            buildAdminCard(
              context, 
              "Gestionar Pacientes", 
              Icons.medical_services_rounded, 
              Colors.orangeAccent,
              () => Navigator.pushNamed(context, AppRoutes.patients),
            ),
            buildAdminCard(
              context, 
              "Añadir Paciente", 
              Icons.person_add_rounded, 
              Colors.redAccent,
              () => Navigator.pushNamed(context, AppRoutes.addPatient),
            ),
            buildAdminCard(
              context, 
              "Incidencias", 
              Icons.warning_amber_rounded, 
              Colors.redAccent,
              () => Navigator.pushNamed(context, AppRoutes.adminIncidences),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAdminCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title, 
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
