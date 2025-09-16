import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon; // ✅ Tambahan untuk ikon opsional

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon, // menambahkan ke constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon, // ✅ Tambahkan di InputDecoration
      ),
    );
  }
}
