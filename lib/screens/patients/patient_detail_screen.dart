import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/app_layout.dart';
import '../../routes/app_routes.dart';
import '../../models/patient.dart';
import '../../providers/patient_provider.dart';
import '../../services/user_service.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
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
    final Patient patientArg =
        ModalRoute.of(context)!.settings.arguments as Patient;
    
    // Obtenemos el paciente del provider para tener actualizaciones en tiempo real
    final patient = context.watch<PatientProvider>().getPatientById(patientArg.id) ?? patientArg;
    final bool isAdmin = _role == 'admin';

    return AppLayout(
      child: Container(
        color: const Color(0xFF2F9C9C),
        child: _isLoadingRole 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// CABECERA PERFIL
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        patient.name.isNotEmpty ? patient.name[0].toUpperCase() : "P",
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF2F9C9C)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${patient.name} ${patient.surname}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (isAdmin)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.editPatient, arguments: patient),
                          ),
                      ],
                    ),
                    Text(
                      "DNI: ${patient.dni}",
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// FICHA MÉDICA E INFORMACIÓN
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("INFORMACIÓN MÉDICA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const Divider(),
                    buildInfoRow("Edad", "${patient.age} años"),
                    buildInfoRow("Sexo", patient.gender),
                    buildInfoRow("Grupo Sanguíneo", patient.bloodType),
                    const Text("ALERGIAS E INTOLERANCIAS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 12)),
                    const Divider(color: Colors.redAccent, thickness: 1),
                    if (patient.allergies.isEmpty)
                      const Text("Ninguna conocida", style: TextStyle(color: Colors.grey))
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: patient.allergies.split(", ").map((a) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                Text(a, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    const SizedBox(height: 15),
                    const Text("RESPONSABLE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const Divider(),
                    buildInfoRow("Cuidador", patient.caregiverName),
                    const SizedBox(height: 15),
                    const Text("NOTAS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const Divider(),
                    Text(patient.notes.isEmpty ? "Sin notas adicionales" : patient.notes),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// ACCIONES
              buildOption(context, Icons.medication_outlined, "Ver Medicaciones", AppRoutes.medications, patient),
              const SizedBox(height: 12),
              if (isAdmin) ...[
                buildOption(context, Icons.add_circle_outline, "Añadir Medicación", AppRoutes.addMedication, patient),
                const SizedBox(height: 12),
              ],
              buildOption(context, Icons.calendar_month_outlined, "Citas Médicas", AppRoutes.appointments, patient),
              const SizedBox(height: 12),
              if (isAdmin) ...[
                buildOption(context, Icons.edit_note, "Modificar Datos", AppRoutes.editPatient, patient),
                const SizedBox(height: 12),
                buildAddAppointmentButton(context, patient),
                const SizedBox(height: 30),
                buildDeleteButton(context, patient),
                const SizedBox(height: 40),
              ] else ...[
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget buildOption(
    BuildContext context,
    IconData icon,
    String text,
    String route,
    Patient patient,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route, arguments: patient);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddAppointmentButton(BuildContext context, Patient patient) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.addAppointment, arguments: patient);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_alarm, size: 26, color: Colors.black),
            const SizedBox(width: 12),
            Text("Añadir Cita Médica", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget buildDeleteButton(BuildContext context, Patient patient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: () {
          context.read<PatientProvider>().deletePatient(patient);
          Navigator.pop(context);
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFFB71C1C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Eliminar paciente",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

