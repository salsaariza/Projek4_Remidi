import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final List<String> items;
  final void Function(String) onChanged;

  const DropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 🔑 radius
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 🔑 radius
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 🔑 radius
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
