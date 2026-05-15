import 'package:flutter/material.dart';
import '../../services/incidence_service.dart';
import '../../models/incidence.dart';
import '../../widgets/common/app_layout.dart';

class IncidencesScreen extends StatelessWidget {
  const IncidencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Container(
        color: const Color(0xFF2F9C9C),
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Panel de Incidencias",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Incidence>>(
                stream: IncidenceService.getIncidencesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No hay incidencias registradas", style: TextStyle(color: Colors.white70)),
                    );
                  }

                  final incidences = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: incidences.length,
                    itemBuilder: (context, index) {
                      final inc = incidences[index];
                      final bool isResolved = inc.status == 'resolved';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: inc.type == 'medication' ? Colors.orange.shade100 : Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      inc.type.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: inc.type == 'medication' ? Colors.orange.shade800 : Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${inc.createdAt.day}/${inc.createdAt.month} ${inc.createdAt.hour}:${inc.createdAt.minute.toString().padLeft(2, '0')}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(inc.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text(inc.description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              const Divider(height: 25),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      "Paciente: ${inc.patientName}",
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.medical_services, size: 16, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      "Cuidador: ${inc.caregiverName}",
                                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!isResolved)
                                    TextButton.icon(
                                      onPressed: () => IncidenceService.resolveIncidence(inc.id),
                                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                      label: const Text("Resolver", style: TextStyle(color: Colors.green)),
                                    ),
                                  if (isResolved)
                                    const Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                                        SizedBox(width: 5),
                                        Text("Resuelta", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  IconButton(
                                    onPressed: () => _confirmDelete(context, inc.id),
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar incidencia"),
        content: const Text("¿Estás seguro de que quieres borrar este registro?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              IncidenceService.deleteIncidence(id);
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
