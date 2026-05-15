import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../widgets/common/app_layout.dart';

import '../../providers/appointment_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/patient_provider.dart';

import '../../models/appointment.dart';
import '../../models/medication.dart';
import '../../models/patient.dart';
import '../../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentUserName = "Usuario";
  bool _isDialogOpen = false;
  String _role = 'caregiver';
  bool _isLoadingRole = true;
  
  // Registro persistente en la sesión para evitar repeticiones
  final Set<String> _processedIds = {};
  
  // Vigilante en segundo plano
  Timer? _appointmentWatcher;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    Future.microtask(() {
      context.read<AppointmentProvider>().startListening();
      context.read<MedicationProvider>().startListeningAll();
      context.read<PatientProvider>().startListening();
      
      // Iniciar el vigilante cada 3 segundos
      _startWatcher();
    });
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
  void dispose() {
    _appointmentWatcher?.cancel();
    super.dispose();
  }

  void _startWatcher() {
    _appointmentWatcher = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || _isDialogOpen) return;
      
      final provider = context.read<AppointmentProvider>();
      final appointments = provider.getTodayAppointments()
          .where((a) => a.status == 'scheduled').toList();
          
      _checkOverdue(appointments);
    });
  }

  void _checkOverdue(List<Appointment> appointments) {
    if (_isDialogOpen || !mounted) return;

    final now = DateTime.now();
    Appointment? found;

    for (var appt in appointments) {
      if (_processedIds.contains(appt.id)) continue;

      try {
        final parts = appt.time.split(':');
        final apptDate = DateTime(appt.date.year, appt.date.month, appt.date.day, int.parse(parts[0]), int.parse(parts[1]));

        if (apptDate.isBefore(now)) {
          found = appt;
          // Marcamos como procesado ANTES de lanzar el diálogo para blindar contra duplicados
          _processedIds.add(appt.id);
          // También marcamos duplicados de contenido si existen
          for (var a in appointments) {
            if (a.patientId == appt.patientId && a.time == appt.time && a.place == appt.place) {
              _processedIds.add(a.id);
            }
          }
          break;
        }
      } catch (e) {
        debugPrint("Error watcher: $e");
      }
    }

    if (found != null) {
      setState(() => _isDialogOpen = true);
      _showAttendanceDialog(found);
    }
  }

  void _showAttendanceDialog(Appointment appt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.notification_important, color: Color(0xFFF39C12)),
            SizedBox(width: 10),
            Text("Confirmar Cita", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("¿Se ha realizado la cita médica de ${appt.patientName} en ${appt.place}?\n\nHora: ${appt.time}"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AppointmentProvider>().updateStatus(appt.id, 'delayed');
              if (mounted) setState(() => _isDialogOpen = false);
            },
            child: const Text("NO, RETRASADA", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F9C9C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AppointmentProvider>().updateStatus(appt.id, 'completed');
              if (mounted) setState(() => _isDialogOpen = false);
            },
            child: const Text("SÍ, REALIZADA"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = context.watch<AppointmentProvider>();
    final medicationProvider = context.watch<MedicationProvider>();

    final List<Appointment> appointmentsToday = appointmentProvider.getTodayAppointments()
        .where((a) => a.status != 'completed').toList();
    
    final List<Medication> activeMedications = medicationProvider.medications;
    final List<String> takenIds = medicationProvider.todayIntakeIds;

    final bool isAdmin = _role == 'admin';

    return AppLayout(
      child: Container(
        color: const Color(0xFF2F9C9C),
        width: double.infinity,
        height: double.infinity,
        child: _isLoadingRole 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
          children: [
            const SizedBox(height: 20),

            /// CABECERA
            StreamBuilder<DocumentSnapshot>(
              stream: UserService.getUserProfileStream(),
              builder: (context, snapshot) {
                String name = "Usuario";
                String? photoUrl;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final firstName = data['name'] ?? "Usuario";
                  final lastName = data['surname'] ?? "";
                  name = "$firstName $lastName".trim();
                  currentUserName = name;
                  photoUrl = data['photoUrl'];
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null ? const Icon(Icons.person, color: Color(0xFF2F9C9C), size: 28) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hola, $name", 
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const Text("Control Diario", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// ACCESOS RÁPIDOS
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildQuickAction(context, Icons.people_rounded, "Pacientes", AppRoutes.patients, const Color(0xFFE74C3C)),
                  buildQuickAction(context, Icons.calendar_month_rounded, "Agenda", AppRoutes.agenda, const Color(0xFFF39C12)),
                  buildQuickAction(context, Icons.emergency_rounded, "Emergencia", AppRoutes.emergency, const Color(0xFFC0392B)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// SECCIÓN CITAS
            buildHeader("CITAS PARA HOY", Icons.calendar_today, appointmentsToday.length),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: appointmentsToday.isEmpty
                  ? buildEmptyState("Sin citas para hoy")
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 10),
                      itemCount: appointmentsToday.length,
                      itemBuilder: (context, index) => buildAppointmentCard(context, appointmentsToday[index], isAdmin),
                    ),
            ),

            const SizedBox(height: 20),

            /// SECCIÓN MEDICACIÓN
            buildHeader("MEDICACIÓN PRÓXIMA", Icons.medication, activeMedications.length),
            const SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: activeMedications.isEmpty
                  ? buildEmptyState("Sin tratamientos activos")
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: activeMedications.length,
                      itemBuilder: (context, index) => buildMedicationCard(context, activeMedications[index], takenIds.contains(activeMedications[index].id)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(String title, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
            ],
          ),
          if (count > 0)
            Text("$count pendientes", style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget buildEmptyState(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
      child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 13)),
    );
  }

  Widget buildQuickAction(BuildContext context, IconData icon, String label, String route, Color color) {
    return GestureDetector(
      onTap: () {
        if (route == AppRoutes.emergency) {
          _showSOSConfirmation(context);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        children: [
          Container(
            width: 55, height: 55,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))]),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showSOSConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("¿Activar SOS?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Se enviará una señal de alerta a las autoridades y se compartirá tu ubicación en tiempo real. ¿Deseas continuar?",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.emergency);
            },
            child: const Text("SÍ, ACTIVAR"),
          ),
        ],
      ),
    );
  }

  Widget buildAppointmentCard(BuildContext context, Appointment appt, bool isAdmin) {
    final bool isDelayed = appt.status == 'delayed';

    return GestureDetector(
      onTap: isAdmin ? () => Navigator.pushNamed(context, AppRoutes.editAppointment, arguments: appt) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDelayed ? const Color(0xFFFDEDEC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isDelayed ? Border.all(color: Colors.redAccent, width: 1.5) : null,
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: isDelayed ? Colors.red : const Color(0xFFF39C12), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appt.patientName, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDelayed ? Colors.red[900] : Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    appt.place, 
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(appt.time, style: TextStyle(color: isDelayed ? Colors.red : const Color(0xFFF39C12), fontWeight: FontWeight.bold, fontSize: 14)),
                if (isDelayed)
                  const Text("RETRASO", style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget buildMedicationCard(BuildContext context, Medication med, bool isTaken) {
    String displayName = med.patientName;
    if (displayName == 'Paciente' || displayName.isEmpty) {
      final patients = context.read<PatientProvider>().patients;
      final patient = patients.cast<Patient?>().firstWhere((p) => p?.id == med.patientId, orElse: () => null);
      if (patient != null) {
        displayName = "${patient.name} ${patient.surname}";
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTaken ? Colors.white.withOpacity(0.85) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: isTaken ? Colors.green : Colors.orange, size: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, decoration: isTaken ? TextDecoration.lineThrough : null),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  "Para: $displayName", 
                  style: const TextStyle(color: Color(0xFF2F9C9C), fontSize: 11, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (isTaken)
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24)
          else
            GestureDetector(
              onTap: () => showConfirmTake(context, med),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF2F9C9C), borderRadius: BorderRadius.circular(8)),
                child: const Text("TOMAR", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  void showConfirmTake(BuildContext context, Medication med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmar Toma"),
        content: Text("¿Confirmas que se ha tomado ${med.name} (${med.dosage})?", style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("NO")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F9C9C), foregroundColor: Colors.white),
            onPressed: () {
              context.read<MedicationProvider>().confirmIntake(med, currentUserName);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Toma registrada correctamente"), backgroundColor: Colors.green));
            },
            child: const Text("SÍ, TOMADA"),
          ),
        ],
      ),
    );
  }
}
