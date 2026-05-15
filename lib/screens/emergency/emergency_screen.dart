import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  String _status = "Iniciando protocolo SOS...";
  bool _isSent = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _startSimulation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startSimulation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _status = "Obteniendo coordenadas GPS...");
    
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _status = "Conectando con Guardia Civil (112)...");

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _status = "SEÑAL ENVIADA: Ubicación compartida con éxito.";
      _isSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.security, color: Color(0xFF2F9C9C), size: 32),
                  Image.asset("assets/nombre_logo.png", height: 30),
                  Image.asset("assets/logo.png", height: 36),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2F9C9C), Color(0xFF1F6A6A)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ANIMACIÓN PULSANTE
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_isSent)
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Container(
                                width: 160 * _animation.value,
                                height: 160 * _animation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withOpacity(1 - _controller.value),
                                ),
                              );
                            },
                          ),
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                            ],
                          ),
                          child: Icon(
                            _isSent ? Icons.check_circle : Icons.emergency_share,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    Text(
                      _isSent ? "EMERGENCIA ACTIVADA" : "SOLICITANDO AYUDA",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isSent)
                            const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                          if (!_isSent) const SizedBox(width: 15),
                          Flexible(
                            child: Text(
                              _status,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        "Mantenga la calma. Un equipo de la Guardia Civil y emergencias está procesando su solicitud.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),

                    const SizedBox(height: 60),

                    buildCancelButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
      child: Container(
        width: 240,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: const Center(
          child: Text(
            "CANCELAR PROTOCOLO",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
