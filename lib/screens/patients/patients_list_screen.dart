import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/app_layout.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/patient_card.dart';

import '../../providers/patient_provider.dart';
import '../../models/patient.dart';
import '../../services/user_service.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  bool loaded = false;
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
    /// Cargar pacientes solo una vez
    if (!loaded) {
      Future.microtask(() {
        Provider.of<PatientProvider>(context, listen: false).loadPatients();
      });

      loaded = true;
    }

    /// Escuchar cambios del provider
    final patients = context.watch<PatientProvider>().patients;
    final bool isAdmin = _role == 'admin';

    return AppLayout(
      child: Container(
        color: const Color(0xFF2F9C9C),

        child: _isLoadingRole 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Lista de pacientes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            /// LISTA DE PACIENTES
            Expanded(
              child: patients.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay pacientes registrados",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: patients.length,

                      itemBuilder: (context, index) {
                        final Patient patient = patients[index];

                        return PatientCard(
                          name: patient.name,
                          age: "${patient.age} años",

                          /// Abrir detalle del paciente
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.patientDetail,
                              arguments: patient,
                            );
                          },
                        );
                      },
                    ),
            ),

            if (isAdmin) ...[
              const SizedBox(height: 10),
              buildAddButton(context),
              const SizedBox(height: 30),
            ] else ...[
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  /// BOTÓN AÑADIR PACIENTE
  Widget buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.addPatient);
      },

      child: Container(
        width: 220,
        height: 45,

        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 1.5),
        ),

        child: const Center(
          child: Text(
            "Añadir Paciente",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
