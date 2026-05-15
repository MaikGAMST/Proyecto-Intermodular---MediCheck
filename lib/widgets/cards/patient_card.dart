import 'package:flutter/material.dart';

class PatientCard extends StatelessWidget {
  final String name;
  final String age;
  final VoidCallback onTap;

  const PatientCard({
    super.key,
    required this.name,
    required this.age,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        elevation: 3,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF2F9C9C),
            child: Icon(Icons.person, color: Colors.white),
          ),

          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),

          subtitle: Text(age),

          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}
