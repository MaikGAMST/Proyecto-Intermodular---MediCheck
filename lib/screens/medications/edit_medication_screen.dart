import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/app_layout.dart';
import '../../widgets/inputs/text_input.dart';
import '../../widgets/buttons/primary_button.dart';

import '../../models/medication.dart';
import '../../providers/medication_provider.dart';

class EditMedicationScreen extends StatefulWidget {
  const EditMedicationScreen({super.key});

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  /// Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();

  /// Fechas del tratamiento
  DateTime? startDate;
  DateTime? endDate;

  String medicationType = "Pastilla";
  String medicationFrequency = "Diario";

  late Medication medication;

  bool loaded = false;

  /// Seleccionar fecha de inicio
  Future<void> pickStartDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() {
        startDate = date;
      });
    }
  }

  /// Seleccionar fecha de finalización
  Future<void> pickEndDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() {
        endDate = date;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Recibir medicación
    medication = ModalRoute.of(context)!.settings.arguments as Medication;

    /// Cargar datos solo una vez
    if (!loaded) {
      nameController.text = medication.name;
      dosageController.text = medication.dosage;

      startDate = medication.startDate;
      endDate = medication.endDate;

      medicationType = medication.type;
      medicationFrequency = medication.frequency;

      loaded = true;
    }

    return AppLayout(
      child: Container(
        width: double.infinity,
        color: const Color(0xFF2F9C9C),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Icon(Icons.edit, size: 40, color: Colors.white),

            const SizedBox(height: 8),

            const Text(
              "Editar medicación",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// MEDICAMENTO
                    const Text(
                      "Medicamento",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text("Nombre del medicamento"),

                    const SizedBox(height: 6),

                    TextInput(
                      hint: "Nombre del medicamento",
                      controller: nameController,
                    ),

                    const SizedBox(height: 20),

                    /// DOSIS
                    const Text("Dosis"),

                    const SizedBox(height: 6),

                    TextInput(hint: "Ej: 500 mg", controller: dosageController),

                    const SizedBox(height: 20),

                    /// TIPO MEDICAMENTO
                    const Text("Tipo de medicamento"),

                    const SizedBox(height: 6),

                    Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 10),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: medicationType,

                          items: const [
                            DropdownMenuItem(
                              value: "Pastilla",
                              child: Text("Pastilla"),
                            ),
                            DropdownMenuItem(
                              value: "Jarabe",
                              child: Text("Jarabe"),
                            ),
                            DropdownMenuItem(
                              value: "Inyección",
                              child: Text("Inyección"),
                            ),
                          ],

                          onChanged: (value) {
                            setState(() {
                              medicationType = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// FRECUENCIA
                    const Text("Frecuencia"),

                    const SizedBox(height: 6),

                    Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 10),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: medicationFrequency,

                          items: const [
                            DropdownMenuItem(
                              value: "Cada 6h",
                              child: Text("Cada 6h"),
                            ),
                            DropdownMenuItem(
                              value: "Cada 8h",
                              child: Text("Cada 8h"),
                            ),
                            DropdownMenuItem(
                              value: "Cada 12h",
                              child: Text("Cada 12h"),
                            ),
                            DropdownMenuItem(
                              value: "Diario",
                              child: Text("Diario"),
                            ),
                            DropdownMenuItem(
                              value: "Semanal",
                              child: Text("Semanal"),
                            ),
                          ],

                          onChanged: (value) {
                            setState(() {
                              medicationFrequency = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// FECHAS
                    const Text(
                      "Duración del tratamiento",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text("Fecha de inicio"),

                    const SizedBox(height: 6),

                    GestureDetector(
                      onTap: pickStartDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          startDate == null
                              ? "Seleccionar fecha"
                              : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text("Fecha de finalización"),

                    const SizedBox(height: 6),

                    GestureDetector(
                      onTap: pickEndDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          endDate == null
                              ? "Seleccionar fecha"
                              : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    /// GUARDAR CAMBIOS
                    Center(
                      child: PrimaryButton(
                        text: "Guardar cambios",
                        onTap: () {
                          if (nameController.text.isEmpty ||
                              dosageController.text.isEmpty ||
                              startDate == null ||
                              endDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Completa todos los campos"),
                              ),
                            );

                            return;
                          }

                          final updatedMedication = medication.copyWith(
                            name: nameController.text,
                            dosage: dosageController.text,
                            frequency: medicationFrequency,
                            startDate: startDate!,
                            endDate: endDate!,
                            type: medicationType,
                          );

                          Provider.of<MedicationProvider>(
                            context,
                            listen: false,
                          ).updateMedication(updatedMedication);

                          Navigator.pop(context);
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// ELIMINAR TRATAMIENTO
                    Center(
                      child: PrimaryButton(
                        text: "Eliminar tratamiento",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Eliminar tratamiento"),
                                content: const Text(
                                  "¿Seguro que quieres eliminar este tratamiento?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Provider.of<MedicationProvider>(
                                        context,
                                        listen: false,
                                      ).deleteMedication(medication.id);

                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Eliminar"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
