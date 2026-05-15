import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Términos y Condiciones"),
        backgroundColor: const Color(0xFF2F9C9C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Términos de Uso y Política de Privacidad",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F9C9C)),
            ),
            const SizedBox(height: 20),
            buildSection("1. Aceptación de los Términos", 
              "Al registrarse en MediCheck, usted acepta cumplir con estos términos. Esta aplicación está diseñada exclusivamente para la gestión de cuidados médicos y no sustituye el consejo profesional."),
            buildSection("2. Uso de la Información", 
              "Los datos de salud introducidos (pacientes, medicaciones, citas) son almacenados de forma segura en Firebase. MediCheck no comparte esta información con terceros sin su consentimiento explícito."),
            buildSection("3. Responsabilidad", 
              "El usuario es responsable de la exactitud de los datos introducidos. MediCheck no se hace responsable de errores en la administración de medicamentos derivados de una mala configuración por parte del usuario."),
            buildSection("4. Restricción de Edad", 
              "El uso de MediCheck está restringido a personas mayores de 18 años."),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F9C9C), foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context),
                child: const Text("He leído y comprendido"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }
}
