import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final String patient;
  final String place;
  final String time;

  const AppointmentCard({
    super.key,
    required this.patient,
    required this.place,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(8),
            ),

            child: const Icon(Icons.medical_services_outlined),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  patient,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 3),

                Text(place),

                const SizedBox(height: 3),

                Text("Hora: $time"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
