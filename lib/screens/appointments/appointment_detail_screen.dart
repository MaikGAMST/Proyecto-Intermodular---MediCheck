import 'package:flutter/material.dart';
import '../../widgets/common/app_layout.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String patient;
  final String place;
  final String time;

  const AppointmentDetailScreen({
    super.key,
    required this.patient,
    required this.place,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Container(
        color: const Color(0xFF2F9C9C),
        width: double.infinity,

        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(Icons.calendar_month, size: 70, color: Colors.white),

            const SizedBox(height: 20),

            Text(
              patient,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              place,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),

            const SizedBox(height: 10),

            Text(
              "Hora: $time",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),

            const SizedBox(height: 40),

            buildButton(),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget buildButton() {
    return Container(
      width: 220,
      height: 45,

      decoration: BoxDecoration(
        color: const Color(0xFFE74C3C),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1.5),
      ),

      child: const Center(
        child: Text(
          "Modificar cita",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
