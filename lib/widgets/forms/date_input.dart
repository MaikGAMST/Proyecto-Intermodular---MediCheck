import 'package:flutter/material.dart';

class DateInput extends StatelessWidget {
  final String hint;

  const DateInput({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),

        child: TextField(
          keyboardType: TextInputType.number,

          decoration: InputDecoration(hintText: hint, border: InputBorder.none),
        ),
      ),
    );
  }
}
