import 'package:flutter/material.dart';

class DropdownInput extends StatelessWidget {
  final List<String> items;
  final String value;
  final Function(String?) onChanged;

  const DropdownInput({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,

          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),

          onChanged: onChanged,
        ),
      ),
    );
  }
}
