import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final String hint;
  final bool obscure;

  /// Controller opcional para poder leer el valor del campo
  final TextEditingController? controller;

  const TextInput({
    super.key,
    required this.hint,
    this.obscure = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        obscureText: obscure,

        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}
