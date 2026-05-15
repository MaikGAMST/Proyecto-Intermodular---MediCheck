import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/app_layout.dart';
import '../../widgets/inputs/text_input.dart';
import '../../widgets/buttons/primary_button.dart';

import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';

class EditAppointmentScreen extends StatefulWidget {
  const EditAppointmentScreen({super.key});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final TextEditingController placeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  late Appointment appointment;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!initialized) {
      appointment = ModalRoute.of(context)!.settings.arguments as Appointment;

      placeController.text = appointment.place;

      selectedDate = appointment.date;

      final timeParts = appointment.time.split(":");
      selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );

      initialized = true;
    }
  }

  /// Seleccionar fecha
  Future<void> pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  /// Seleccionar hora
  Future<void> pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  /// Guardar cambios
  void saveChanges() {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);

    final String timeStr =
        "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    // Lógica de Reactivación Automática
    final DateTime now = DateTime.now();
    final DateTime appointmentDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    String newStatus = appointment.status;
    if (appointmentDateTime.isAfter(now)) {
      // Si la nueva fecha/hora es futura, la ponemos en 'scheduled' automáticamente
      newStatus = 'scheduled';
    }

    final updatedAppointment = appointment.copyWith(
      place: placeController.text.trim(),
      time: timeStr,
      date: selectedDate!,
      status: newStatus,
    );

    provider.updateAppointment(updatedAppointment);
    Navigator.pop(context);
  }

  /// Confirmar eliminación
  void confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar cita"),
          content: const Text("¿Seguro que quieres eliminar esta cita?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AppointmentProvider>(
                  context,
                  listen: false,
                ).removeAppointment(appointment.id);

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Container(
        width: double.infinity,
        color: const Color(0xFF2F9C9C),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                "Modificar cita",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              /// PACIENTE (SOLO INFORMACIÓN)
              const Text("Paciente"),
              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(appointment.patientName),
              ),

              const SizedBox(height: 20),

              /// LUGAR
              const Text("Lugar"),
              const SizedBox(height: 6),

              TextInput(
                hint: "Hospital / Centro médico",
                controller: placeController,
              ),

              const SizedBox(height: 20),

              /// FECHA
              const Text("Fecha"),
              const SizedBox(height: 6),

              GestureDetector(
                onTap: pickDate,
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
                    selectedDate == null
                        ? "Seleccionar fecha"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// HORA
              const Text("Hora"),
              const SizedBox(height: 6),

              GestureDetector(
                onTap: pickTime,
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
                    selectedTime == null
                        ? "Seleccionar hora"
                        : selectedTime!.format(context),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: PrimaryButton(
                  text: "Guardar cambios",
                  onTap: saveChanges,
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: PrimaryButton(
                  text: "Eliminar cita",
                  onTap: confirmDelete,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
