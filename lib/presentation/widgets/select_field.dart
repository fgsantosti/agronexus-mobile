import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SelectItem extends Equatable {
  final String value;
  final String label;

  const SelectItem({
    required this.value,
    required this.label,
  });

  @override
  List<Object?> get props => [value, label];
}

class ANSelectField extends StatefulWidget {
  final List<SelectItem> items;
  final SelectItem? selectedItem;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final Function(SelectItem?)? onChanged;
  const ANSelectField({
    super.key,
    required this.items,
    this.selectedItem,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.onChanged,
  });

  @override
  State<ANSelectField> createState() => _ANSelectFieldState();
}

class _ANSelectFieldState extends State<ANSelectField> {
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        helperText: widget.helperText,
        border: const OutlineInputBorder(),
      ),
      isEmpty: widget.selectedItem == null,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SelectItem>(
          value: widget.selectedItem,
          isDense: true,
          onChanged: widget.onChanged,
          items: widget.items.map<DropdownMenuItem<SelectItem>>(
            (SelectItem item) {
              return DropdownMenuItem<SelectItem>(
                value: item,
                child: Text(item.label),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
