import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/inputs/text_input.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, rellena todos los campos")),
      );
      setState(() => _isLoading = false);
      return;
    }

    final user = await _authService.signInWithEmailAndPassword(email, password);

    if (user != null) {
      // 1. Obtener datos del usuario
      final userData = await UserService.getUserData(user.uid);
      final role = userData?['role'] ?? 'caregiver';
      final isActive = userData?['isActive'] ?? false;

      if (role != 'admin' && !isActive) {
        // Cuenta inactiva, cerramos sesión
        await AuthService().signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tu cuenta está pendiente de activación por un administrador."),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      if (mounted) {
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al iniciar sesión. Comprueba tus credenciales.")),
        );
      }
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO
              Image.asset("assets/logo.png", height: 140),
              const SizedBox(height: 50),

              // TARJETA LOGIN
              Container(
                width: 300,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F9C9C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Image.asset("assets/nombre_logo.png", height: 55),
                    const SizedBox(height: 20),

                    TextInput(
                      hint: "Email",
                      controller: _emailController,
                    ),
                    const SizedBox(height: 15),

                    TextInput(
                      hint: "Contraseña",
                      obscure: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 20),

                    _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : PrimaryButton(
                          text: "Inicia Sesión",
                          onTap: _login,
                        ),

                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text(
                        "¿No tienes cuenta? Regístrate",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.recoverPassword),
                      child: const Text(
                        "¿Recordar contraseña?",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
