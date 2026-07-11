import 'package:flutter/material.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  // initialValue may not be present in `items` (e.g. loaded from an entity/DB/API).
  // Keep it nullable and, if it's not present, inject it into the items list so
  // DropdownButtonFormField's assertion is satisfied.
  final T? initialValue;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String labelText;
  final String? Function(T?)? validator;
  final bool isExpanded;

  const CustomDropdownFormField({
    Key? key,
    this.initialValue,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.labelText,
    this.validator,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure the DropdownButtonFormField items contain the initialValue (if any).
    // If initialValue is not present in the provided items, prepend it so the
    // underlying DropdownButton won't assert.
    final List<T> itemsForDropdown = (initialValue != null && !items.contains(initialValue))
        ? [initialValue as T, ...items]
        : items;

    return DropdownButtonFormField<T>(
      initialValue: itemsForDropdown.contains(initialValue) ? initialValue : null,
      items: itemsForDropdown
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

