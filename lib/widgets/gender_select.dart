import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const GenderSelector({super.key, required this.onChanged});

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  String _selected = "Laki-Laki";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Jenis Kelamin"),
        Row(
          children: [
            Radio<String>(
              value: "Laki-Laki",
              groupValue: _selected,
              onChanged: (value) {
                setState(() => _selected = value!);
                widget.onChanged(value!);
              },
            ),
            const Text("Laki-Laki"),
            Radio<String>(
              value: "Perempuan",
              groupValue: _selected,
              onChanged: (value) {
                setState(() => _selected = value!);
                widget.onChanged(value!);
              },
            ),
            const Text("Perempuan"),
          ],
        ),
      ],
    );
  }
}
