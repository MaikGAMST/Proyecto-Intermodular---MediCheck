import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/inputs/text_input.dart';
import '../../widgets/buttons/primary_button.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _recoverPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, introduce tu email")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.sendPasswordResetEmail(email);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email de recuperación enviado. Revisa tu bandeja de entrada.")),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al enviar el email. Verifica que la dirección sea correcta.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // LOGO
              Image.asset("assets/logo.png", height: 120),

              const SizedBox(height: 40),

              // TARJETA
              Container(
                width: 300,
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: const Color(0xFF2F9C9C),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  children: [
                    Image.asset("assets/nombre_logo.png", height: 50),

                    const SizedBox(height: 20),

                    // ICONO CANDADO
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.lock_outline,
                        size: 60,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "¿Tienes problemas para iniciar sesión?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Introduce tu correo electrónico y te enviaremos un enlace para que vuelvas a entrar en tu cuenta.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),

                    const SizedBox(height: 15),

                    TextInput(
                      hint: "Correo electrónico...",
                      controller: _emailController,
                    ),

                    const SizedBox(height: 18),

                    _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : PrimaryButton(
                          text: "Recuperar cuenta",
                          onTap: _recoverPassword,
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
