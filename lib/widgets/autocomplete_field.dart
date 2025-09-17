import 'package:flutter/material.dart';

class AutocompleteField extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? initialValue;
  final void Function(String) onSelected;
  final String? Function(String?)? validator;

  const AutocompleteField({
    super.key,
    required this.label,
    required this.options,
    required this.onSelected,
    this.initialValue,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: initialValue != null ? TextEditingValue(text: initialValue!) : null,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (BuildContext context, TextEditingController controller, 
          FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            suffixIcon: const Icon(Icons.search),
          ),
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, 
          Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: index < options.length - 1 
                            ? Border(bottom: BorderSide(color: Colors.grey.shade300))
                            : null,
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}