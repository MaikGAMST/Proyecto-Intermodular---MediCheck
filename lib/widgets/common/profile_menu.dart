import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileMenu extends StatefulWidget {
  final VoidCallback? onLogout;

  const ProfileMenu({
    super.key,
    this.onLogout,
  });

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  String _role = 'caregiver';
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await UserService.getUserRole();
    if (mounted) {
      setState(() {
        _role = role;
        _isLoadingRole = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _role == 'admin';

    return Row(
      children: [
        /// PANEL MENU
        Container(
          width: 270,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF2F9C9C),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 0),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER PERFIL
              StreamBuilder<DocumentSnapshot>(
                stream: UserService.getUserProfileStream(),
                builder: (context, snapshot) {
                  String name = "Usuario";
                  String? photoUrl;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final firstName = data['name'] ?? 'Usuario';
                    final lastName = data['surname'] ?? '';
                    name = "$firstName $lastName".trim();
                    photoUrl = data['photoUrl'];
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    color: Colors.white,

                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFF2F9C9C),
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null 
                              ? const Icon(Icons.person, color: Colors.white, size: 28)
                              : null,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),

                              Text(
                                isAdmin ? "Administrador" : "Cuidador",
                                style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              /// OPCIONES
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _isLoadingRole 
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : ListView(
                    children: [
                      menuItem(
                        icon: Icons.home_outlined,
                        text: "Inicio",
                        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                      ),

                      const SizedBox(height: 20),

                      menuItem(
                        icon: Icons.people_outline,
                        text: "Mis Pacientes",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.patients),
                      ),

                      const SizedBox(height: 20),

                      if (isAdmin) ...[
                        menuItem(
                          icon: Icons.admin_panel_settings_outlined,
                          text: "Panel de Administración",
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminHome),
                        ),
                        const SizedBox(height: 20),
                      ],

                      menuItem(
                        icon: Icons.settings_outlined,
                        text: "Configuración",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                      ),

                      const SizedBox(height: 20),

                      menuItem(
                        icon: Icons.description_outlined,
                        text: "Términos y Privacidad",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
                      ),

                      const SizedBox(height: 30),
                      const Divider(color: Colors.white54),
                      const SizedBox(height: 20),

                      menuItem(
                        icon: Icons.logout,
                        text: "Cerrar sesión",
                        color: Colors.white,
                        onTap: widget.onLogout,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        /// LINEA ROJA
        Container(width: 4, color: const Color(0xFFE74C3C)),
      ],
    );
  }

  Widget menuItem({
    required IconData icon,
    required String text,
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

