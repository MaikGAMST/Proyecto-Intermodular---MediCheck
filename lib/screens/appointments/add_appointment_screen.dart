import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/app_layout.dart';
import '../../widgets/inputs/text_input.dart';
import '../../widgets/buttons/primary_button.dart';

import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final TextEditingController placeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String patientName = "";
  String patientId = "";
  String caregiverId = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Patient) {
      patientName = args.name;
      patientId = args.id;
      caregiverId = args.caregiverId;
    }
  }

  Future<void> pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day), // Solo hoy o futuro
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void saveAppointment() {
    if (placeController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    // Validar que no sea en el pasado
    final DateTime now = DateTime.now();
    final DateTime appointmentDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (appointmentDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No puedes programar una cita en el pasado"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final provider = Provider.of<AppointmentProvider>(context, listen: false);

    final String timeStr =
        "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    final newAppointment = Appointment(
      id: "", // Lo genera el servicio
      patientId: patientId,
      caregiverId: caregiverId,
      patientName: patientName,
      place: placeController.text.trim(),
      time: timeStr,
      date: selectedDate!,
    );

    provider.addAppointment(newAppointment);
    Navigator.pop(context);
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
                "Añadir cita médica",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

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
                child: Text(patientName),
              ),

              const SizedBox(height: 20),

              const Text("Lugar"),
              const SizedBox(height: 6),

              TextInput(
                hint: "Hospital / Centro médico",
                controller: placeController,
              ),

              const SizedBox(height: 20),

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
                  text: "Guardar cita",
                  onTap: saveAppointment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
