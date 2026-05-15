import 'package:flutter/material.dart';
import 'app_header.dart';
import 'profile_menu.dart';
import 'app_bottom_nav.dart';

class AppLayout extends StatefulWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool showMenu = false;

  void toggleMenu() {
    setState(() {
      showMenu = !showMenu;
    });
  }

  void closeMenu() {
    setState(() {
      showMenu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),

      body: SafeArea(
        child: Stack(
          children: [
            /// CONTENIDO PRINCIPAL
            Column(
              children: [
                /// HEADER
                AppHeader(onProfileTap: toggleMenu),

                /// CONTENIDO DE LA PANTALLA
                Expanded(child: widget.child),
              ],
            ),

            /// OVERLAY OSCURO
            if (showMenu)
              GestureDetector(
                onTap: closeMenu,

                child: Container(
                  color: Colors.black54,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

            /// MENU LATERAL ANIMADO
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: showMenu ? 0 : -260,
              top: 0,
              bottom: 0,

              child: ProfileMenu(
                onLogout: () {
                  closeMenu();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),

      /// BARRA INFERIOR
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
