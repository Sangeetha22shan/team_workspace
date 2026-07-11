import 'package:flutter/material.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final T initialValue;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String labelText;
  final String? Function(T?)? validator;
  final bool isExpanded;

  const CustomDropdownFormField({
    Key? key,
    required this.initialValue,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.labelText,
    this.validator,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
      isExpanded: isExpanded,
    );
  }
}

