import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/app_layout.dart';
import '../../widgets/cards/appointment_card.dart';

import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = Provider.of<AppointmentProvider>(context).appointments;

    /// ordenar citas por fecha
    appointments.sort((a, b) => a.date.compareTo(b.date));

    return AppLayout(
      child: Container(
        width: double.infinity,
        color: const Color(0xFF2F9C9C),

        child: Column(
          children: [
            const SizedBox(height: 10),

            const Icon(Icons.calendar_month, size: 40, color: Colors.white),

            const SizedBox(height: 8),

            const Text(
              "Agenda médica",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final Appointment appointment = appointments[index];

                  return AppointmentCard(
                    patient: appointment.patientName,
                    place: appointment.place,
                    time: appointment.time,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/editAppointment",
                        arguments: appointment,
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
}
