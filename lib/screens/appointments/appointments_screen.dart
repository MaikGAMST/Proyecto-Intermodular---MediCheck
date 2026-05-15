import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/app_layout.dart';
import '../../widgets/cards/appointment_card.dart';
import '../../routes/app_routes.dart';

import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../services/user_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../services/incidence_service.dart';
import '../../models/incidence.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
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

  void _showReportDialog(Appointment appointment, Patient patient) {
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reportar Incidencia: Cita Médica"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cita en: ${appointment.place}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Describe el problema (ej: transporte fallido, paciente indispuesto...)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;
              
              final incidence = Incidence(
                id: '',
                type: 'appointment',
                title: "Problema con cita en ${appointment.place}",
                description: descController.text.trim(),
                caregiverId: user.uid,
                caregiverName: user.email ?? "Cuidador",
                patientId: patient.id,
                patientName: "${patient.name} ${patient.surname}",
                createdAt: DateTime.now(),
              );

              await IncidenceService.reportIncidence(incidence);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incidencia reportada al administrador"), backgroundColor: Colors.orange),
                );
              }
            },
            child: const Text("Reportar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Patient patient = ModalRoute.of(context)!.settings.arguments as Patient;
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final List<Appointment> appointments = appointmentProvider.appointments
        .where((a) => a.patientId == patient.id)
        .toList();

    final bool isAdmin = _role == 'admin';

    return AppLayout(
      child: Container(
        color: const Color(0xFF2F9C9C),
        child: _isLoadingRole 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Citas de ${patient.name}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: appointments.isEmpty
                  ? const Center(child: Text("No hay citas registradas", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];

                        return Row(
                          children: [
                            Expanded(
                              child: AppointmentCard(
                                patient: appointment.patientName,
                                place: appointment.place,
                                time: appointment.time,
                                onTap: isAdmin ? () {
                                  Navigator.pushNamed(context, AppRoutes.editAppointment, arguments: appointment);
                                } : () {},
                              ),
                            ),
                            if (!isAdmin)
                              IconButton(
                                icon: const Icon(Icons.report_problem_rounded, color: Colors.orangeAccent),
                                onPressed: () => _showReportDialog(appointment, patient),
                                tooltip: "Reportar incidencia",
                              ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            if (isAdmin)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addAppointment, arguments: patient);
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
                  child: Text("Añadir cita médica", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ) else const SizedBox(height: 20),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

