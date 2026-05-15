import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/cards/medication_card.dart';

import '../../providers/medication_provider.dart';
import '../../models/medication.dart';
import '../../models/patient.dart';
import '../../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/incidence_service.dart';
import '../../models/incidence.dart';

class MedicationsListScreen extends StatefulWidget {
  const MedicationsListScreen({super.key});

  @override
  State<MedicationsListScreen> createState() => _MedicationsListScreenState();
}

class _MedicationsListScreenState extends State<MedicationsListScreen> {
  bool _loaded = false;
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

  void _showReportDialog(Medication medication, Patient patient) {
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reportar Incidencia: ${medication.name}"),
        content: TextField(
          controller: descController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Describe el problema (ej: falta stock, efectos secundarios...)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;
              
              final incidence = Incidence(
                id: '',
                type: 'medication',
                title: "Problema con ${medication.name}",
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
    final String patientId = patient.id;

    if (!_loaded) {
      Future.microtask(() {
        Provider.of<MedicationProvider>(context, listen: false).startListeningPatient(patientId);
      });
      _loaded = true;
    }

    final bool isAdmin = _role == 'admin';

    return AppLayout(
      child: Container(
        color: const Color(0xFF2F9C9C),
        child: _isLoadingRole 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Consumer<MedicationProvider>(
          builder: (context, provider, child) {
            final List<Medication> medications = provider.medications;

            return Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Medicaciones",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),

                if (medications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Este paciente aún no tiene tratamientos registrados",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: medications.length,
                    itemBuilder: (context, index) {
                      final medication = medications[index];

                      return Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: isAdmin ? () {
                                Navigator.pushNamed(context, AppRoutes.editMedication, arguments: medication);
                              } : null,
                              child: MedicationCard(
                                name: medication.name,
                                dosage: medication.dosage,
                                frequency: "${medication.frequency} - ${medication.type}",
                                date: "${medication.endDate.day}/${medication.endDate.month}/${medication.endDate.year}",
                              ),
                            ),
                          ),
                          if (!isAdmin)
                            IconButton(
                              icon: const Icon(Icons.report_problem_rounded, color: Colors.orangeAccent),
                              onPressed: () => _showReportDialog(medication, patient),
                              tooltip: "Reportar incidencia",
                            ),
                        ],
                      );
                    },
                  ),
                ),

                if (isAdmin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.addMedication, arguments: patient);
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
                        child: Text("Añadir medicación", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ) else const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

